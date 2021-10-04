# -*- coding: utf-8 -*-

request.requires_https()

def user(): return dict(form=auth())

def callback(): return sber.history(sber.history.insert(request=request.vars, function='callback')).response

@auth.requires_login()
def index():
    tablename = request.args(0) or 'table'
    tables = list(set([item for sublist in [db.tables() for db in databases.values()] for item in sublist]))
    if not tablename in tables: redirect(URL())
    grids = dict()
    for db in databases.values():
        if not tablename in db.tables(): continue
        db.set_represent_for(tablename)
        auth.set_represent_for(tablename)
        vars = dict(
            args=request.args[:1],
            create=False,
            deletable=False,
            details=False,
            editable=False,
            exportclasses=dict(tsv=False, tsv_with_hidden_cols=False, csv_with_hidden_cols=False, xml=False, html=False, json=False),
            formname='_'.join((db._adapter.driver_args['database'], tablename)),
            links=[],
            maxtextlength=512,
            user_signature=True,
        )
        table = db[tablename]
        if 'id' in table:
            if tablename == 'table': vars['orderby'] = table.id
            else: vars['orderby'] = ~table.id
        if tablename == 'table':
            vars.update(csv=False, searchable=False, fields=[table.id], groupby=table.id)
        response.title = T(db[tablename]._plural)
        grids[str(T(db._adapter.driver_args['database'].capitalize()))] = SQLFORM.grid(table, **vars)
    return grids

@auth.requires_login()
def load(): return CAT(
    A('Счета', _href=URL('bill_load'))
)

@auth.requires_login()
def bill_load():
    s = StringIO()
    cherry().select(cherry.bill.ALL).export_to_csv_file(s, represent=True, delimiter=';', quoting=csv.QUOTE_NONE, quotechar='\'', write_colnames=False, null='')
    e = s.getvalue()
    now = (datetime(request.now.year, request.now.month, 1) - relativedelta(months=1)).strftime('%Y_%m')
    response.headers['Content-Type'] = 'text/csv; charset=windows-1251'
    response.headers['Content-Disposition'] = f'attachment;filename=4T_BIL_{now}.csv;'
    raise HTTP(200, f'{e}'.encode('windows-1251'), **response.headers)
