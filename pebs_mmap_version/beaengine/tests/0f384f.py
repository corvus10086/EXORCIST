
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


        # EVEX.LIG.66.0F38.W0 4f /r
        # vrsqrt14ss xmm1 {k1}{z}, xmm2/m128/m32bcst

        myEVEX = EVEX('EVEX.LIG.66.0F38.W0')
        Buffer = '{}4f20'.format(myEVEX.prefix()).decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(myDisasm.infos.Instruction.Opcode, 0x4f)
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'vrsqrt14ss ')
        assert_equal(myDisasm.infos.repr, 'vrsqrt14ss xmm28, xmmword ptr [r8]')


        # EVEX.LIG.66.0F38.W1 4f /r
        # vrsqrt14sd xmm1 {k1}{z}, xmm2/m128/m64bcst

        myEVEX = EVEX('EVEX.LIG.66.0F38.W1')
        Buffer = '{}4f20'.format(myEVEX.prefix()).decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(myDisasm.infos.Instruction.Opcode, 0x4f)
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'vrsqrt14sd ')
        assert_equal(myDisasm.infos.repr, 'vrsqrt14sd xmm28, xmmword ptr [r8]')
