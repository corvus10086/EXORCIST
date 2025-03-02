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

        # VEX.128.66.0F38.W0 79 /r
        # vpbroadcastw xmm1, xmm2/m16

        myVEX = VEX('VEX.128.66.0F38.W0')
        myVEX.vvvv = 0b1111
        Buffer = '{}7920'.format(myVEX.c4()).decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(myDisasm.infos.Instruction.Opcode, 0x79)
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'vpbroadcastw ')
        assert_equal(myDisasm.infos.repr, 'vpbroadcastw xmm12, word ptr [r8]')

        # VEX.256.66.0F38.W0 79 /r
        # vpbroadcastw ymm1, xmm2/m16

        myVEX = VEX('VEX.256.66.0F38.W0')
        myVEX.vvvv = 0b1111
        Buffer = '{}7920'.format(myVEX.c4()).decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(myDisasm.infos.Instruction.Opcode, 0x79)
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'vpbroadcastw ')
        assert_equal(myDisasm.infos.repr, 'vpbroadcastw ymm12, word ptr [r8]')

        # EVEX.128.66.0F38.W0 79 /r
        # vpbroadcastw xmm1{k1}{z}, xmm2/m16

        myEVEX = EVEX('EVEX.128.66.0F38.W0')
        Buffer = '{}790e'.format(myEVEX.prefix()).decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(myDisasm.infos.Instruction.Opcode, 0x79)
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'vpbroadcastw ')
        assert_equal(myDisasm.infos.repr, 'vpbroadcastw xmm25, word ptr [r14]')

        # EVEX.256.66.0F38.W0 79 /r
        # vpbroadcastw ymm1{k1}{z}, xmm2/m16

        myEVEX = EVEX('EVEX.256.66.0F38.W0')
        Buffer = '{}790e'.format(myEVEX.prefix()).decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(myDisasm.infos.Instruction.Opcode, 0x79)
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'vpbroadcastw ')
        assert_equal(myDisasm.infos.repr, 'vpbroadcastw ymm25, word ptr [r14]')

        # EVEX.512.66.0F38.W0 79 /r
        # vpbroadcastw zmm1{k1}{z}, xmm2/m16

        myEVEX = EVEX('EVEX.512.66.0F38.W0')
        Buffer = '{}790e'.format(myEVEX.prefix()).decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(myDisasm.infos.Instruction.Opcode, 0x79)
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'vpbroadcastw ')
        assert_equal(myDisasm.infos.repr, 'vpbroadcastw zmm25, word ptr [r14]')
