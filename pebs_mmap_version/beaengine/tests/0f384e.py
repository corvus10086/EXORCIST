
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


        # EVEX.128.66.0F38.W0 4E /r
        # VRSQRT14PS xmm1 {k1}{z}, xmm2/m128/m32bcst

        myEVEX = EVEX('EVEX.128.66.0F38.W0')
        Buffer = '{}4e20'.format(myEVEX.prefix()).decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(myDisasm.infos.Instruction.Opcode, 0x4e)
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'vrsqrt14ps ')
        assert_equal(myDisasm.infos.repr, 'vrsqrt14ps xmm28, xmmword ptr [r8]')

        # EVEX.256.66.0F38.W0 4E /r
        # VRSQRT14PS ymm1 {k1}{z}, ymm2/m256/m32bcst

        myEVEX = EVEX('EVEX.256.66.0F38.W0')
        Buffer = '{}4e20'.format(myEVEX.prefix()).decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(myDisasm.infos.Instruction.Opcode, 0x4e)
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'vrsqrt14ps ')
        assert_equal(myDisasm.infos.repr, 'vrsqrt14ps ymm28, ymmword ptr [r8]')

        # EVEX.512.66.0F38.W0 4E /r
        # VRSQRT14PS zmm1 {k1}{z}, zmm2/m512/m32bcst

        myEVEX = EVEX('EVEX.512.66.0F38.W0')
        Buffer = '{}4e20'.format(myEVEX.prefix()).decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(myDisasm.infos.Instruction.Opcode, 0x4e)
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'vrsqrt14ps ')
        assert_equal(myDisasm.infos.repr, 'vrsqrt14ps zmm28, zmmword ptr [r8]')

        # EVEX.128.66.0F38.W1 4E /r
        # VRSQRT14PD xmm1 {k1}{z}, xmm2/m128/m64bcst

        myEVEX = EVEX('EVEX.128.66.0F38.W1')
        Buffer = '{}4e20'.format(myEVEX.prefix()).decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(myDisasm.infos.Instruction.Opcode, 0x4e)
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'vrsqrt14pd ')
        assert_equal(myDisasm.infos.repr, 'vrsqrt14pd xmm28, xmmword ptr [r8]')

        # EVEX.256.66.0F38.W1 4E /r
        # VRSQRT14PD ymm1 {k1}{z}, ymm2/m256/m64bcst

        myEVEX = EVEX('EVEX.256.66.0F38.W1')
        Buffer = '{}4e20'.format(myEVEX.prefix()).decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(myDisasm.infos.Instruction.Opcode, 0x4e)
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'vrsqrt14pd ')
        assert_equal(myDisasm.infos.repr, 'vrsqrt14pd ymm28, ymmword ptr [r8]')

        # EVEX.512.66.0F38.W1 4E /r
        # VRSQRT14PD zmm1 {k1}{z}, zmm2/m512/m64bcst

        myEVEX = EVEX('EVEX.512.66.0F38.W1')
        Buffer = '{}4e20'.format(myEVEX.prefix()).decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(myDisasm.infos.Instruction.Opcode, 0x4e)
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'vrsqrt14pd ')
        assert_equal(myDisasm.infos.repr, 'vrsqrt14pd zmm28, zmmword ptr [r8]')
