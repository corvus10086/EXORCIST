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


        # EVEX.128.66.0F38.W0 7b /r
        # vpbroadcastw xmm1 {k1}{z}, reg

        myEVEX = EVEX('EVEX.128.66.0F38.W0')
        Buffer = '{}7bc0'.format(myEVEX.prefix()).decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(myDisasm.infos.Instruction.Opcode, 0x7b)
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'vpbroadcastw ')
        assert_equal(myDisasm.infos.repr, 'vpbroadcastw xmm24, r8w')

        # EVEX.256.66.0F38.W0 7b /r
        # vpbroadcastw ymm1 {k1}{z}, reg

        myEVEX = EVEX('EVEX.256.66.0F38.W0')
        Buffer = '{}7bc0'.format(myEVEX.prefix()).decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(myDisasm.infos.Instruction.Opcode, 0x7b)
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'vpbroadcastw ')
        assert_equal(myDisasm.infos.repr, 'vpbroadcastw ymm24, r8w')

        # EVEX.512.66.0F38.W0 7b /r
        # vpbroadcastw zmm1 {k1}{z}, reg

        myEVEX = EVEX('EVEX.512.66.0F38.W0')
        Buffer = '{}7bc0'.format(myEVEX.prefix()).decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(myDisasm.infos.Instruction.Opcode, 0x7b)
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'vpbroadcastw ')
        assert_equal(myDisasm.infos.repr, 'vpbroadcastw zmm24, r8w')
