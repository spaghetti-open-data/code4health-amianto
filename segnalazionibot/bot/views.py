# -*- coding: utf-8 -*-
import logging
import telepot
from datetime import datetime

from django.db import transaction
from django.core.files.base import ContentFile
from django.core import management
from django.conf import settings
from django.shortcuts import render_to_response
from django.template import RequestContext
from bot.models import TelegramMessage, TelegramUser, Bot, Segnalazione
from django.http import HttpResponse

logger = logging.getLogger(__name__)

def process_messages(request):
#     # test_davideg
#     bot = telepot.Bot('234267785:AAHzxruE5Xf3Ms6bg445jlS6nKdldftq5ls')
    # davide_test_bot
    bot = Bot.objects.get(pk=1)
    bot.telepot = telepot.Bot(bot.token)
    
    bot.telepot.getMe()
    responses = bot.telepot.getUpdates()
    for response in responses:
        try:
            with transaction.atomic():
                # messaggio già processato ?
                m_id = response['message']['message_id']
                if len(list(TelegramMessage.objects.filter(telegram_message_id = m_id))) == 0:
                    # esiste l'utente ?
                    if len(TelegramUser.objects.filter(telegram_id = response['message']['from']['id'])) == 0:
                        ut = TelegramUser()
                        ut.telegram_id = response['message']['from']['id']
                        ut.first_name = response['message']['from']['first_name']
                        ut.last_name = response['message']['from']['last_name']
                        ut.save()
                    else:
                        ut = TelegramUser.objects.get(telegram_id = response['message']['from']['id'])
                        if 'username' in response['message']['from'].keys() and ut.username !=  response['message']['from']['username']:
                            ut.username =  response['message']['from']['username']
                            ut.save()
                    
                    m = TelegramMessage()
                    # parte comune
                    m.when_sent = datetime.fromtimestamp(response['message']['date'])
                    m.telegram_message_id = response['message']['message_id']
                    m.utente = ut
                    m.bot = bot
        
                    if 'text' in response['message'].keys():
                        m.text = response['message']['text']
                    if 'location' in response['message'].keys():
                        m.longitude = response['message']['location']['longitude']
                        m.latitude = response['message']['location']['latitude']
                    if 'photo' in response['message'].keys():
                        thumb_number = 0
                        thumb_path = settings.TMP + str(response['message']['message_id']) + 't.jpg' 
                        bot.telepot.download_file(response['message']['photo'][thumb_number]['file_id'], thumb_path)
                        f = open(thumb_path, 'rb')
                        flat_txt = f.read()
                        m.photo_thumb.save(str(response['message']['message_id']) + 't.jpg', ContentFile(flat_txt))
                        
                        hires_number = 3
                        hires_path = settings.TMP + str(response['message']['message_id']) + 'h.jpg' 
                        bot.telepot.download_file(response['message']['photo'][hires_number]['file_id'], hires_path)
                        f = open(hires_path, 'rb')
                        flat_txt = f.read()
                        m.photo_hires.save(str(response['message']['message_id']) + 'h.jpg', ContentFile(flat_txt))
                        if 'caption' in response['message'].keys():
                            m.caption = response['message']['caption']
                    m.save()
        except Exception as ex:
            logger.error(str(ex))
    return HttpResponse("OK")

def list_messages(request):
    try:
        bot_messages = list(TelegramMessage.objects.all())
        bot_messages = sorted(bot_messages, key=lambda message: message.when_sent)
        cont = RequestContext(request, {'bot_messages':bot_messages})
        logger.warning("list_messages trovati %s messaggi." % len(bot_messages))
        return render_to_response('bot/list_messages.html', context_instance=cont)
    except Exception as ex:
        return HttpResponse(str(ex))

def list_segnalazioni(request):
    try:
        segnalazioni = list(Segnalazione.objects.all())
        segnalazioni = sorted(segnalazioni, key=lambda segnalazione: segnalazione.photo_message.when_sent)
        cont = RequestContext(request, {'segnalazioni':segnalazioni})
        return render_to_response('bot/list_segnalazioni.html', context_instance=cont)
    except Exception as ex:
        return HttpResponse(str(ex))

def aggiorna_marker(request):
    try:
        target = open(settings.BASE_DIR + "/static/maps/markers.json", 'w')    
        target.truncate()
        target.write("markers = [\n")
        for segnalazione in Segnalazione.objects.all():
            target.write("  {\n")
            target.write(('    "when": "%s",\n' % segnalazione.photo_message.when_sent))
            target.write(('    "thumb": "%s",\n' % segnalazione.photo_message.photo_thumb.url))
            target.write(('    "hires": "%s",\n' % segnalazione.photo_message.photo_hires.url))
            if segnalazione.photo_message.photo_caption:
                target.write(('    "caption": "%s",\n' % segnalazione.photo_message.photo_caption))
            else:
                target.write('    "caption": "",\n')
            target.write(('    "lat": "%s",\n' % segnalazione.location_message.latitude))
            target.write(('    "lng": "%s"\n' % segnalazione.location_message.longitude))
            target.write("  },\n")
        target.write("]\n")
        target.close()
        return HttpResponse("OK")
    except Exception as ex:
        return HttpResponse(str(ex))
    
    
def debug(request):
    management.call_command('processbot')