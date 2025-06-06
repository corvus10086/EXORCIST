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

        # 66 0F 3A 0d /r ib
        # blendpd xmm1, xmm2/m128, imm8

        Buffer = '660f3a0d2011'.decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(myDisasm.infos.Instruction.Opcode, 0x0f3a0d)
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'blendpd ')
        assert_equal(myDisasm.infos.repr, 'blendpd xmm4, xmmword ptr [rax], 11h')

        # VEX.128.66.0F3A.WIG 0d /r ib
        # Vblendpd xmm1, xmm2, xmm3/m128, imm8

        myVEX = VEX('VEX.128.66.0F3A.WIG')
        Buffer = '{}0d1033'.format(myVEX.c4()).decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(myDisasm.infos.Instruction.Opcode, 0x0d)
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'vblendpd ')
        assert_equal(myDisasm.infos.repr, 'vblendpd xmm10, xmmword ptr [r8], 33h')

        # VEX.256.66.0F3A.WIG 0d /r ib
        # Vblendpd ymm1, ymm2, ymm3/m256, imm8

        myVEX = VEX('VEX.256.66.0F3A.WIG')
        Buffer = '{}0d1033'.format(myVEX.c4()).decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(myDisasm.infos.Instruction.Opcode, 0x0d)
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'vblendpd ')
        assert_equal(myDisasm.infos.repr, 'vblendpd ymm10, ymmword ptr [r8], 33h')
