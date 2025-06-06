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

        # 66 0F 7C /r
        # HADDPD xmm1, xmm2/m128

        Buffer = '660f7c90'.decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(myDisasm.infos.Instruction.Opcode, 0xf7c)
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'haddpd ')
        assert_equal(myDisasm.infos.repr, 'haddpd xmm2, xmmword ptr [rax+00000000h]')

        # VEX.NDS.128.66.0F.WIG 7C /r
        # VHADDPD xmm1,xmm2, xmm3/m128

        myVEX = VEX('VEX.NDS.128.66.0F.WIG')
        Buffer = '{}7c90'.format(myVEX.c4()).decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(myDisasm.infos.Instruction.Opcode, 0x7c)
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'vhaddpd ')
        assert_equal(myDisasm.infos.repr, 'vhaddpd xmm10, xmm15, xmmword ptr [r8+00000000h]')

        # VEX.NDS.256.66.0F.WIG 7C /r
        # VHADDPD ymm1, ymm2, ymm3/m256

        myVEX = VEX('VEX.NDS.256.66.0F.WIG')
        Buffer = '{}7c90'.format(myVEX.c4()).decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(myDisasm.infos.Instruction.Opcode, 0x7c)
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'vhaddpd ')
        assert_equal(myDisasm.infos.repr, 'vhaddpd ymm10, ymm15, ymmword ptr [r8+00000000h]')

        # F2 0F 7C /r
        # HADDPS xmm1, xmm2/m128

        Buffer = 'f20f7c90'.decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(hex(myDisasm.infos.Instruction.Opcode), '0xf7c')
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'haddps ')
        assert_equal(myDisasm.infos.repr, 'haddps xmm2, xmmword ptr [rax+00000000h]')

        # VEX.NDS.128.F2.0F.WIG 7C /r
        # VHADDPS xmm1, xmm2, xmm3/m128

        myVEX = VEX('VEX.NDS.128.F2.0F.WIG')
        Buffer = '{}7c90'.format(myVEX.c4()).decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(myDisasm.infos.Instruction.Opcode, 0x7c)
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'vhaddps ')
        assert_equal(myDisasm.infos.repr, 'vhaddps xmm10, xmm15, xmmword ptr [r8+00000000h]')

        # VEX.NDS.256.F2.0F.WIG 7C /r
        # VHADDPS ymm1, ymm2, ymm3/m256

        myVEX = VEX('VEX.NDS.256.F2.0F.WIG')
        Buffer = '{}7c90'.format(myVEX.c4()).decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(myDisasm.infos.Instruction.Opcode, 0x7c)
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'vhaddps ')
        assert_equal(myDisasm.infos.repr, 'vhaddps ymm10, ymm15, ymmword ptr [r8+00000000h]')
