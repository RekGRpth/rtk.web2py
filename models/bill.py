# -*- coding: utf-8 -*-

cherry.define_table('bill', rname='bill_view_rtk', migrate=False, singular='Счёт', plural='Счета', on_define=lambda table: (
), *(
    Field('id', type='integer', label='Порядковый номер позиции в файле'),
    Field('contract_number', label='Номер клиентского договора'),
    Field('contract_date', type='date', label='Дата клиентского договора'),
    Field('client_name', label='Наименование'),
))
