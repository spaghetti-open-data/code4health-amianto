#!/usr/bin/env python
# -*- coding: utf-8 -*-
# Subject to the terms of the GNU AFFERO GENERAL PUBLIC LICENSE, v. 3.0. If a copy of the AGPL was not
# distributed with this file, You can obtain one at http://www.gnu.org/licenses/agpl.txt
#
# Author: Davide Galletti                davide   ( at )   c4k.it

from django.conf.urls import patterns, url

from bot import views

urlpatterns = [
    url(r'^process_messages/$', views.process_messages, name='process_messages'),
    url(r'^list_messages/$', views.list_messages, name='list_messages'),
    url(r'^list_segnalazioni/$', views.list_segnalazioni, name='list_segnalazioni'),
    url(r'^aggiorna_marker/$', views.aggiorna_marker, name='aggiorna_marker'),
    url(r'^debug/$', views.debug, name='debug'),
]