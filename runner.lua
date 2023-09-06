p = require('piz8')
pp = require('pprint')

local f = io.open(arg[1], 'rb')

p.load(f:read('*all'))

p.eval()
print('Stack:')
pp.pprint(p.stack)