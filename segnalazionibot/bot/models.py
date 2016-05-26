from django.db import models
import telepot

class Bot(models.Model):
    nome = models.CharField(max_length=750)
    token = models.CharField(max_length=200)
    active = models.BooleanField(default=False)
    group_text_with_location = models.BooleanField(default=True)
    group_photo_with_location = models.BooleanField(default=True)
    location_first = models.BooleanField(default=True)

class TelegramUser(models.Model):
    telegram_id = models.IntegerField()
    first_name = models.CharField(max_length=255, default='')
    last_name = models.CharField(max_length=255, default='')
    username = models.CharField(max_length=255, default='')

class TelegramMessage(models.Model):
    bot = models.ForeignKey(Bot)
    telegram_message_id = models.IntegerField()
    utente = models.ForeignKey(TelegramUser)
    chat_id = models.CharField(max_length=50, db_index=True)
    content_type = models.CharField(max_length=50, db_index=True)
    # da telegram arriva unixtime
    when_sent = models.DateTimeField()
    when_registered = models.DateTimeField(auto_now_add=True)
    processed = models.BooleanField(default=False, db_index=True)
    #  TextMessage
    text = models.CharField(max_length=2000, default='')
    #  PhotoMessage
    photo_thumb = models.FileField(upload_to='images/')
    photo_hires = models.FileField(upload_to='images/')
    photo_caption = models.CharField(max_length=2000, default='')
    #  LocationMessage
    longitude = models.FloatField(blank=True,null=True, db_index=True)
    latitude = models.FloatField(blank=True,null=True, db_index=True)

class Segnalazione(models.Model):
    photo_message = models.ForeignKey(TelegramMessage, related_name="segnalazione_photo")
    location_message = models.ForeignKey(TelegramMessage, related_name="segnalazione_location")
    
    