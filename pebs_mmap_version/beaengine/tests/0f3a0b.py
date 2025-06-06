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

        # 66 0F 3A 0b /r ib
        # roundsd xmm1, xmm2/m64, imm8

        Buffer = '660f3a0b2011'.decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(myDisasm.infos.Instruction.Opcode, 0x0f3a0b)
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'roundsd ')
        assert_equal(myDisasm.infos.repr, 'roundsd xmm4, qword ptr [rax], 11h')

        Buffer = '660f3a0bc011'.decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(myDisasm.infos.Instruction.Opcode, 0x0f3a0b)
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'roundsd ')
        assert_equal(myDisasm.infos.repr, 'roundsd xmm0, xmm0, 11h')

        # VEX.LIG.66.0F3A.WIG 0b /r ib
        # Vroundsd xmm1, xmm2, xmm3/m64, imm8

        myVEX = VEX('VEX.LIG.66.0F3A.WIG')
        Buffer = '{}0b1033'.format(myVEX.c4()).decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(myDisasm.infos.Instruction.Opcode, 0x0b)
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'vroundsd ')
        assert_equal(myDisasm.infos.repr, 'vroundsd xmm10, xmm0, qword ptr [r8], 33h')

        # EVEX.LIG.66.0F3A.W0 0b /r ib
        # VRNDscalesd xmm1 {k1}{z}, xmm2, xmm3/m64{sae}, imm8

        myEVEX = EVEX('EVEX.LIG.66.0F3A.W0')
        Buffer = '{}0b2011'.format(myEVEX.prefix()).decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(myDisasm.infos.Instruction.Opcode, 0x0b)
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'vrndscalesd ')
        assert_equal(myDisasm.infos.repr, 'vrndscalesd xmm28, xmm16, qword ptr [r8], 11h')
