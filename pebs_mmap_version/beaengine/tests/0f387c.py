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


        # EVEX.128.66.0F38.W0 7c /r
        # vpbroadcastd xmm1 {k1}{z}, reg

        myEVEX = EVEX('EVEX.128.66.0F38.W0')
        Buffer = '{}7cc0'.format(myEVEX.prefix()).decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(myDisasm.infos.Instruction.Opcode, 0x7c)
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'vpbroadcastd ')
        assert_equal(myDisasm.infos.repr, 'vpbroadcastd xmm24, r8d')

        # EVEX.256.66.0F38.W0 7c /r
        # vpbroadcastd ymm1 {k1}{z}, reg

        myEVEX = EVEX('EVEX.256.66.0F38.W0')
        Buffer = '{}7cc0'.format(myEVEX.prefix()).decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(myDisasm.infos.Instruction.Opcode, 0x7c)
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'vpbroadcastd ')
        assert_equal(myDisasm.infos.repr, 'vpbroadcastd ymm24, r8d')

        # EVEX.512.66.0F38.W0 7c /r
        # vpbroadcastd zmm1 {k1}{z}, reg

        myEVEX = EVEX('EVEX.512.66.0F38.W0')
        Buffer = '{}7cc0'.format(myEVEX.prefix()).decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(myDisasm.infos.Instruction.Opcode, 0x7c)
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'vpbroadcastd ')
        assert_equal(myDisasm.infos.repr, 'vpbroadcastd zmm24, r8d')


        # EVEX.128.66.0F38.W1 7c /r
        # vpbroadcastd xmm1 {k1}{z}, reg

        myEVEX = EVEX('EVEX.128.66.0F38.W1')
        Buffer = '{}7cc0'.format(myEVEX.prefix()).decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(myDisasm.infos.Instruction.Opcode, 0x7c)
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'vpbroadcastq ')
        assert_equal(myDisasm.infos.repr, 'vpbroadcastq xmm24, r8')

        # EVEX.256.66.0F38.W1 7c /r
        # vpbroadcastd ymm1 {k1}{z}, reg

        myEVEX = EVEX('EVEX.256.66.0F38.W1')
        Buffer = '{}7cc0'.format(myEVEX.prefix()).decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(myDisasm.infos.Instruction.Opcode, 0x7c)
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'vpbroadcastq ')
        assert_equal(myDisasm.infos.repr, 'vpbroadcastq ymm24, r8')

        # EVEX.512.66.0F38.W1 7c /r
        # vpbroadcastd zmm1 {k1}{z}, reg

        myEVEX = EVEX('EVEX.512.66.0F38.W1')
        Buffer = '{}7cc0'.format(myEVEX.prefix()).decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(myDisasm.infos.Instruction.Opcode, 0x7c)
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'vpbroadcastq ')
        assert_equal(myDisasm.infos.repr, 'vpbroadcastq zmm24, r8')
