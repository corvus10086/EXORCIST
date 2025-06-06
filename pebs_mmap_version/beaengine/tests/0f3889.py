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

        # EVEX.128.66.0F38.W0 89 /r
        # vpexpandd xmm1 {k1}{z}, xmm2/m128

        myEVEX = EVEX('EVEX.128.66.0F38.W0')
        Buffer = '{}890e'.format(myEVEX.prefix()).decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(myDisasm.infos.Instruction.Opcode, 0x89)
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'vpexpandd ')
        assert_equal(myDisasm.infos.repr, 'vpexpandd xmm25, xmmword ptr [r14]')

        # EVEX.256.66.0F38.W0 89 /r
        # vpexpandd ymm1 {k1}{z}, ymm2/m256

        myEVEX = EVEX('EVEX.256.66.0F38.W0')
        Buffer = '{}890e'.format(myEVEX.prefix()).decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(myDisasm.infos.Instruction.Opcode, 0x89)
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'vpexpandd ')
        assert_equal(myDisasm.infos.repr, 'vpexpandd ymm25, ymmword ptr [r14]')

        # EVEX.512.66.0F38.W0 89 /r
        # vpexpandd zmm1 {k1}{z}, zmm2/m512

        myEVEX = EVEX('EVEX.512.66.0F38.W0')
        Buffer = '{}890e'.format(myEVEX.prefix()).decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(myDisasm.infos.Instruction.Opcode, 0x89)
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'vpexpandd ')
        assert_equal(myDisasm.infos.repr, 'vpexpandd zmm25, zmmword ptr [r14]')

        # EVEX.128.66.0F38.W1 89 /r
        # vpexpandq xmm1 {k1}{z}, xmm2/m128

        myEVEX = EVEX('EVEX.128.66.0F38.W1')
        Buffer = '{}890e'.format(myEVEX.prefix()).decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(myDisasm.infos.Instruction.Opcode, 0x89)
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'vpexpandq ')
        assert_equal(myDisasm.infos.repr, 'vpexpandq xmm25, xmmword ptr [r14]')

        # EVEX.256.66.0F38.W1 89 /r
        # vpexpandq ymm1 {k1}{z}, ymm2/m256

        myEVEX = EVEX('EVEX.256.66.0F38.W1')
        Buffer = '{}890e'.format(myEVEX.prefix()).decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(myDisasm.infos.Instruction.Opcode, 0x89)
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'vpexpandq ')
        assert_equal(myDisasm.infos.repr, 'vpexpandq ymm25, ymmword ptr [r14]')

        # EVEX.512.66.0F38.W1 89 /r
        # vpexpandq zmm1 {k1}{z}, zmm2/m512

        myEVEX = EVEX('EVEX.512.66.0F38.W1')
        Buffer = '{}890e'.format(myEVEX.prefix()).decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(myDisasm.infos.Instruction.Opcode, 0x89)
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'vpexpandq ')
        assert_equal(myDisasm.infos.repr, 'vpexpandq zmm25, zmmword ptr [r14]')
