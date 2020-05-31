package = 'grafana-tarantool-datasource-backend'
version = 'scm-1'
source  = {
    url = 'https://github.com/vasiliy-t/grafana-tarantool-datasource-backend',
}
-- Put any modules your app depends on here
dependencies = {
    'tarantool',
    'lua >= 5.1',
    'checks == 3.0.1-1',
    'cartridge == 2.1.2-1',
    'icu-date'
}
build = {
    type = 'bultin',

    modules = {
        ['grafana-tarantool-datasource-backend.grafana_backend'] = 'grafana_backend.lua'
    }
}
