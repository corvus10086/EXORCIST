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


        # VEX.NDS.L1.0F.W0 42 /r
        # kandnW k1, k2, k3

        myVEX = VEX('VEX.NDS.L1.0F.W0')
        myVEX.vvvv = 0b1101
        myVEX.R = 1
        Buffer = '{}42cb'.format(myVEX.c4()).decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(hex(myDisasm.infos.Instruction.Opcode), '0x42')
        assert_equal(myDisasm.infos.Reserved_.VEX.L, 1)
        assert_equal(myDisasm.infos.Reserved_.REX.W_, 0)
        assert_equal(myDisasm.infos.Reserved_.MOD_, 3)
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'kandnw ')
        assert_equal(myDisasm.infos.repr, 'kandnw k1, k2, k3')

        # VEX.L1.66.0F.W0 42 /r
        # kandnB k1, k2, k3

        myVEX = VEX('VEX.L1.66.0F.W0')
        myVEX.vvvv = 0b1101
        myVEX.R = 1
        Buffer = '{}42cb'.format(myVEX.c4()).decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(hex(myDisasm.infos.Instruction.Opcode), '0x42')
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'kandnb ')
        assert_equal(myDisasm.infos.repr, 'kandnb k1, k2, k3')

        # VEX.L1.0F.W1 42 /r
        # kandnQ k1, k2, k3

        myVEX = VEX('VEX.L1.0F.W1')
        myVEX.vvvv = 0b1101
        myVEX.R = 1
        Buffer = '{}42cb'.format(myVEX.c4()).decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(hex(myDisasm.infos.Instruction.Opcode), '0x42')
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'kandnq ')
        assert_equal(myDisasm.infos.repr, 'kandnq k1, k2, k3')

        # VEX.L1.66.0F.W1 42 /r
        # kandnD k1, k2, k3

        myVEX = VEX('VEX.L1.66.0F.W1')
        myVEX.vvvv = 0b1101
        myVEX.R = 1
        Buffer = '{}42cb'.format(myVEX.c4()).decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(hex(myDisasm.infos.Instruction.Opcode), '0x42')
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'kandnd ')
        assert_equal(myDisasm.infos.repr, 'kandnd k1, k2, k3')
