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


        # 0F 38 f1 /r
        # MOVBE m32, r32

        Buffer = '0f38f120'.decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(myDisasm.infos.Instruction.Opcode, 0xf38f1)
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'movbe ')
        assert_equal(myDisasm.infos.repr, 'movbe dword ptr [rax], esp')

        # REX.W + 0F 38 f1 /r
        # MOVBE m64, r64

        myREX = REX()
        myREX.W = 1

        Buffer = '{:02x}0f38f127'.format(myREX.byte()).decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(myDisasm.infos.Instruction.Opcode, 0xf38f1)
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'movbe ')
        assert_equal(myDisasm.infos.repr, 'movbe qword ptr [rdi], rsp')

        # F2 0F 38 F1 /r
        # CRC32 r32, r/m32

        Buffer = 'f20f38f120'.decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(myDisasm.infos.Instruction.Opcode, 0xf38f1)
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'crc32 ')
        assert_equal(myDisasm.infos.repr, 'crc32 esp, dword ptr [rax]')

        # F2 REX.W 0F 38 F1 /r
        # CRC32 r64, r/m64

        myREX = REX()
        myREX.W = 1
        Buffer = 'f2{:02x}0f38f127'.format(myREX.byte()).decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(myDisasm.infos.Instruction.Opcode, 0xf38f1)
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'crc32 ')
        assert_equal(myDisasm.infos.repr, 'crc32 rsp, qword ptr [rdi]')
