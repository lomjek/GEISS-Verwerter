env = Environment(
    DC='ldc2'
)

sources = Glob('*.d')

sources += Glob('./token/*.d')

env.Program(target='repl.dc', source=sources)