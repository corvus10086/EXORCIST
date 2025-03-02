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

        # 66 0F 3A 08 /r ib
        # roundps xmm1, xmm2/m128, imm8

        Buffer = '660f3a082011'.decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(myDisasm.infos.Instruction.Opcode, 0x0f3a08)
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'roundps ')
        assert_equal(myDisasm.infos.repr, 'roundps xmm4, xmmword ptr [rax], 11h')

        # VEX.128.66.0F3A.WIG 08 /r ib
        # Vroundps xmm1, xmm2/m128, imm8

        myVEX = VEX('VEX.128.66.0F3A.WIG')
        Buffer = '{}081033'.format(myVEX.c4()).decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(myDisasm.infos.Instruction.Opcode, 0x08)
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'vroundps ')
        assert_equal(myDisasm.infos.repr, 'vroundps xmm10, xmmword ptr [r8], 33h')

        # VEX.256.66.0F3A.WIG 08 /r ib
        # Vroundps ymm1, ymm2/m256, imm8

        myVEX = VEX('VEX.256.66.0F3A.WIG')
        Buffer = '{}081033'.format(myVEX.c4()).decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(myDisasm.infos.Instruction.Opcode, 0x08)
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'vroundps ')
        assert_equal(myDisasm.infos.repr, 'vroundps ymm10, ymmword ptr [r8], 33h')

        # EVEX.128.66.0F3A.W0 08 /r ib
        # VRNDSCALEPS xmm1 {k1}{z}, xmm2/m128/m32bcst, imm8

        myEVEX = EVEX('EVEX.128.66.0F3A.W0')
        Buffer = '{}082011'.format(myEVEX.prefix()).decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(myDisasm.infos.Instruction.Opcode, 0x08)
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'vrndscaleps ')
        assert_equal(myDisasm.infos.repr, 'vrndscaleps xmm28, xmmword ptr [r8], 11h')

        # EVEX.256.66.0F3A.W0 08 /r ib
        # VRNDSCALEPS ymm1 {k1}{z}, ymm2/m256/m32bcst, imm8

        myEVEX = EVEX('EVEX.256.66.0F3A.W0')
        Buffer = '{}082011'.format(myEVEX.prefix()).decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(myDisasm.infos.Instruction.Opcode, 0x08)
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'vrndscaleps ')
        assert_equal(myDisasm.infos.repr, 'vrndscaleps ymm28, ymmword ptr [r8], 11h')

        # EVEX.512.66.0F3A.W0 08 /r ib
        # VRNDSCALEPS zmm1 {k1}{z}, zmm2/m512/m32bcst{sae}, imm8

        myEVEX = EVEX('EVEX.512.66.0F3A.W0')
        Buffer = '{}082011'.format(myEVEX.prefix()).decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(myDisasm.infos.Instruction.Opcode, 0x08)
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'vrndscaleps ')
        assert_equal(myDisasm.infos.repr, 'vrndscaleps zmm28, zmmword ptr [r8], 11h')
