# -*- coding: utf-8 -*-

from datetime import datetime
from dateutil.relativedelta import relativedelta
from gluon._compat import StringIO
from myinit import myinit; globals().update(myinit())
import csv

response.form_label_separator = ''
response.formstyle = 'bootstrap4_inline'
response.generic_patterns = ['*'] 
response.meta.author = appconfig.get('app.author')
response.meta.description = appconfig.get('app.description')
response.meta.generator = appconfig.get('app.generator')
response.meta.keywords = ','.join(appconfig.get('app.keywords'))
response.show_toolbar = auth.is_admin() and appconfig.get('app.toolbar')
