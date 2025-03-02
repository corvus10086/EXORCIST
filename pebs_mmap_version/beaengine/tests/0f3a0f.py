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


        # NP 0F 3A 0F /r ib
        # PALIGNR mm1, mm2/m64, imm8

        Buffer = '0f3a0f2011'.decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(myDisasm.infos.Instruction.Opcode, 0x0f3a0f)
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'palignr ')
        assert_equal(myDisasm.infos.repr, 'palignr mm4, qword ptr [rax], 11h')

        # 66 0F 3A 0F /r ib
        # PALIGNR xmm1, xmm2/m128, imm8

        Buffer = '660f3a0f2011'.decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(myDisasm.infos.Instruction.Opcode, 0x0f3a0f)
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'palignr ')
        assert_equal(myDisasm.infos.repr, 'palignr xmm4, xmmword ptr [rax], 11h')

        # VEX.128.66.0F3A.WIG 0F /r ib
        # VPALIGNR xmm1, xmm2, xmm3/m128, imm8

        myVEX = VEX('VEX.128.66.0F3A.WIG')
        Buffer = '{}0f1033'.format(myVEX.c4()).decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(myDisasm.infos.Instruction.Opcode, 0x0f)
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'vpalignr ')
        assert_equal(myDisasm.infos.repr, 'vpalignr xmm10, xmm0, xmmword ptr [r8], 33h')

        # VEX.256.66.0F3A.WIG 0F /r ib
        # VPALIGNR ymm1, ymm2, ymm3/m256, imm8

        myVEX = VEX('VEX.256.66.0F3A.WIG')
        Buffer = '{}0f1033'.format(myVEX.c4()).decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(myDisasm.infos.Instruction.Opcode, 0x0f)
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'vpalignr ')
        assert_equal(myDisasm.infos.repr, 'vpalignr ymm10, ymm0, ymmword ptr [r8], 33h')

        # EVEX.128.66.0F3A.WIG 0F /r ib
        # VPALIGNR xmm1 {k1}{z}, xmm2, xmm3/m128, imm8

        myEVEX = EVEX('EVEX.128.66.0F3A.WIG')
        Buffer = '{}0f2011'.format(myEVEX.prefix()).decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(myDisasm.infos.Instruction.Opcode, 0x0f)
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'vpalignr ')
        assert_equal(myDisasm.infos.repr, 'vpalignr xmm28, xmm16, xmmword ptr [r8], 11h')

        # EVEX.256.66.0F3A.WIG 0F /r ib
        # VPALIGNR ymm1 {k1}{z}, ymm2, ymm3/m256, imm8

        myEVEX = EVEX('EVEX.256.66.0F3A.WIG')
        Buffer = '{}0f2011'.format(myEVEX.prefix()).decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(myDisasm.infos.Instruction.Opcode, 0x0f)
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'vpalignr ')
        assert_equal(myDisasm.infos.repr, 'vpalignr ymm28, ymm16, ymmword ptr [r8], 11h')

        # EVEX.512.66.0F3A.WIG 0F /r ib
        # VPALIGNR zmm1 {k1}{z}, zmm2, zmm3/m512, imm8

        myEVEX = EVEX('EVEX.512.66.0F3A.WIG')
        Buffer = '{}0f2011'.format(myEVEX.prefix()).decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(myDisasm.infos.Instruction.Opcode, 0x0f)
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'vpalignr ')
        assert_equal(myDisasm.infos.repr, 'vpalignr zmm28, zmm16, zmmword ptr [r8], 11h')
