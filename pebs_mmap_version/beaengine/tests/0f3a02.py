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

        # VEX.128.66.0F3A.W0 02 /r ib
        # VPBLENDD xmm1, xmm2, xmm3/m128, imm8

        myVEX = VEX('VEX.128.66.0F3A.W0')
        Buffer = '{}02e011'.format(myVEX.c4()).decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(myDisasm.infos.Instruction.Opcode, 0x02)
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'vpblendd ')
        assert_equal(myDisasm.infos.repr, 'vpblendd xmm12, xmm0, xmm8, 11h')

        # VEX.256.66.0F3A.W0 02 /r ib
        # VPBLENDD ymm1, ymm2, ymm3/m256, imm8

        myVEX = VEX('VEX.256.66.0F3A.W0')
        Buffer = '{}02e011'.format(myVEX.c4()).decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(myDisasm.infos.Instruction.Opcode, 0x02)
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'vpblendd ')
        assert_equal(myDisasm.infos.repr, 'vpblendd ymm12, ymm0, ymm8, 11h')
