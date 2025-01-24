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

        # 66 0F 3A DF /r ib
        # AESKEYGENASSIST xmm1, xmm2/m128, imm8

        Buffer = '660f3adf2033'.decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(myDisasm.infos.Instruction.Opcode, 0xf3adf)
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'aeskeygenassist ')
        assert_equal(myDisasm.infos.repr, 'aeskeygenassist xmm4, xmmword ptr [rax], 33h')

        # VEX.128.66.0F3A.WIG DF /r ib
        # VAESKEYGENASSIST xmm1, xmm2/m128, imm8

        myVEX = VEX('VEX.128.66.0F3A.WIG')
        Buffer = '{}df1033'.format(myVEX.c4()).decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(myDisasm.infos.Instruction.Opcode, 0xdf)
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'vaeskeygenassist ')
        assert_equal(myDisasm.infos.repr, 'vaeskeygenassist xmm10, xmmword ptr [r8], 33h')
