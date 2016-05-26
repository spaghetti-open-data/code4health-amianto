# -*- coding: utf-8 -*-
# Subject to the terms of the GNU AFFERO GENERAL PUBLIC LICENSE, v. 3.0. If a copy of the AGPL was not
# distributed with this file, You can obtain one at http://www.gnu.org/licenses/agpl.txt
#
# Author: Davide Galletti                davide   ( at )   c4k.it

from __future__ import unicode_literals

from django.db import models, migrations
from bot.models import Bot

def forwards_func(apps, schema_editor):
    b = Bot(nome="Test Segnalazioni",token="222270684:AAG8WpqPmqYqenLiHaa2iHEo8B1V76b804k",active=True)
    b.save()
#     b = Bot(nome="Test amianto",token="239323847:AAHX2Lh7UX4YidFoCvWX3nL2dNS3t0JRKPM",active=True)
#     b.save()
    

class Migration(migrations.Migration):

    dependencies = [
        ('bot', '0001_initial'),
    ]

    operations = [
        migrations.RunPython(
            forwards_func,
        ),
    ]

