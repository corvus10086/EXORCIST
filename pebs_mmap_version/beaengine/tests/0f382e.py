
#!/usr/bin/python
# -*- coding: utf-8 -*-
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>
#
# @author : 

from headers.BeaEnginePython import *
from nose.tools import *

class TestSuite:
    def test(self):

        # VEX.128.66.0F38.W0 2e /r
        # vmaskmovps m128, xmm1, xmm2

        myVEX = VEX('VEX.128.66.0F38.W0')
        myVEX.vvvv = 0b1111
        Buffer = '{}2e10'.format(myVEX.c4()).decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(myDisasm.infos.Instruction.Opcode, 0x2e)
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'vmaskmovps ')
        assert_equal(myDisasm.infos.repr, 'vmaskmovps xmmword ptr [r8], xmm0, xmm10')

        # VEX.256.66.0F38.W0 2e /r
        # vmaskmovps m256, ymm1, ymm2

        myVEX = VEX('VEX.256.66.0F38.W0')
        myVEX.vvvv = 0b1111
        Buffer = '{}2e10'.format(myVEX.c4()).decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(myDisasm.infos.Instruction.Opcode, 0x2e)
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'vmaskmovps ')
        assert_equal(myDisasm.infos.repr, 'vmaskmovps ymmword ptr [r8], ymm0, ymm10')
