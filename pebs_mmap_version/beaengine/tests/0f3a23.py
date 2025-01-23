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
# @author : beaengine@gmail.com

from headers.BeaEnginePython import *
from nose.tools import *


class TestSuite:

    def test(self):

        # EVEX.256.66.0F3A.W0 23 /r ib
        # VSHUFF32X4 ymm1{k1}{z}, ymm2, ymm3/m256/m32bcst, imm8

        myEVEX = EVEX('EVEX.256.66.0F3A.W0')
        Buffer = '{}232011'.format(myEVEX.prefix()).decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(myDisasm.infos.Instruction.Opcode, 0x23)
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'vshuff32x4 ')
        assert_equal(myDisasm.infos.repr, 'vshuff32x4 ymm28, ymm16, ymmword ptr [r8], 11h')

        # EVEX.512.66.0F3A.W0 23 /r ib
        # VSHUFF32x4 zmm1{k1}{z}, zmm2, zmm3/m512/m32bcst, imm8

        myEVEX = EVEX('EVEX.512.66.0F3A.W0')
        Buffer = '{}232011'.format(myEVEX.prefix()).decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(myDisasm.infos.Instruction.Opcode, 0x23)
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'vshuff32x4 ')
        assert_equal(myDisasm.infos.repr, 'vshuff32x4 zmm28, zmm16, zmmword ptr [r8], 11h')

        # EVEX.256.66.0F3A.W1 23 /r ib
        # VSHUFF64X2 ymm1{k1}{z}, ymm2, ymm3/m256/m64bcst, imm8

        myEVEX = EVEX('EVEX.256.66.0F3A.W1')
        Buffer = '{}232011'.format(myEVEX.prefix()).decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(myDisasm.infos.Instruction.Opcode, 0x23)
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'vshuff64x2 ')
        assert_equal(myDisasm.infos.repr, 'vshuff64x2 ymm28, ymm16, ymmword ptr [r8], 11h')

        # EVEX.512.66.0F3A.W1 23 /r ib
        # VSHUFF64x2 zmm1{k1}{z}, zmm2, zmm3/m512/m64bcst, imm8

        myEVEX = EVEX('EVEX.512.66.0F3A.W1')
        Buffer = '{}232011'.format(myEVEX.prefix()).decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(myDisasm.infos.Instruction.Opcode, 0x23)
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'vshuff64x2 ')
        assert_equal(myDisasm.infos.repr, 'vshuff64x2 zmm28, zmm16, zmmword ptr [r8], 11h')
