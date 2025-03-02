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

        # NP 0F 6E /r
        # MOVD mm, r/m32

        Buffer = '0f6e20'.decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(hex(myDisasm.infos.Instruction.Opcode), '0xf6e')
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'movd ')
        assert_equal(myDisasm.infos.repr, 'movd mm4, dword ptr [rax]')

        # NP REX.W + 0F 6E /r
        # MOVQ mm, r/m64

        myREX = REX()
        myREX.W = 1
        Buffer = '{:02x}0f6e20'.format(myREX.byte()).decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(hex(myDisasm.infos.Instruction.Opcode), '0xf6e')
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'movq ')
        assert_equal(myDisasm.infos.repr, 'movq mm4, qword ptr [rax]')

        # 66 0F 6E /r
        # MOVD xmm, r/m32

        Buffer = '660f6e20'.decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(hex(myDisasm.infos.Instruction.Opcode), '0xf6e')
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'movd ')
        assert_equal(myDisasm.infos.repr, 'movd xmm4, dword ptr [rax]')

        # 66 REX.W 0F 6E /r
        # MOVQ xmm, r/m64

        myREX = REX()
        myREX.W = 1
        Buffer = '66{:02x}0f6e20'.format(myREX.byte()).decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(hex(myDisasm.infos.Instruction.Opcode), '0xf6e')
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'movq ')
        assert_equal(myDisasm.infos.repr, 'movq xmm4, qword ptr [rax]')

        # VEX.128.66.0F.W0 6E /
        # VMOVD xmm1, r32/m32

        myVEX = VEX('VEX.128.66.0F.W0')
        Buffer = '{}6e20'.format(myVEX.c4()).decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(myDisasm.infos.Instruction.Opcode, 0x6e)
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'vmovd ')
        assert_equal(myDisasm.infos.repr, 'vmovd xmm12, dword ptr [r8]')

        # VEX.128.66.0F.W1 6E /r
        # VMOVQ xmm1, r64/m64

        myVEX = VEX('VEX.128.66.0F.W1')
        Buffer = '{}6e20'.format(myVEX.c4()).decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(myDisasm.infos.Instruction.Opcode, 0x6e)
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'vmovq ')
        assert_equal(myDisasm.infos.repr, 'vmovq xmm12, qword ptr [r8]')

        # EVEX.128.66.0F.W0 6E /r
        # VMOVD xmm1, r32/m32

        myEVEX = EVEX('EVEX.128.66.0F.W0')
        Buffer = '{}6e20'.format(myEVEX.prefix()).decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(myDisasm.infos.Instruction.Opcode, 0x6e)
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'vmovd ')
        assert_equal(myDisasm.infos.repr, 'vmovd xmm28, dword ptr [r8]')

        # EVEX.128.66.0F.W1 6E /r
        # VMOVQ xmm1, r64/m64

        myEVEX = EVEX('EVEX.128.66.0F.W1')
        Buffer = '{}6e20'.format(myEVEX.prefix()).decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(myDisasm.infos.Instruction.Opcode, 0x6e)
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'vmovq ')
        assert_equal(myDisasm.infos.repr, 'vmovq xmm28, qword ptr [r8]')
