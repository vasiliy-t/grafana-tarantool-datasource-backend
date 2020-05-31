package = 'grafana-tarantool-datasource-backend'
version = 'scm-1'
source  = {
    url = 'https://vasiliy-t/grafana-tarantool-datasource-backend.git',
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
    type = 'none';
}
