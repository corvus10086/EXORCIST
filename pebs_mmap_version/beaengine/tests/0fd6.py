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


        # F3 0F D6 /r
        # MOVQ2DQ xmm, mm

        Buffer = 'f30fd6c0'.decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(myDisasm.infos.Instruction.Opcode, 0xfd6)
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'movq2dq ')
        assert_equal(myDisasm.infos.repr, 'movq2dq xmm0, mm0')

        # F2 0F D6 /r
        # MOVDQ2Q mm, xmm

        Buffer = 'f20fd6c0'.decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(myDisasm.infos.Instruction.Opcode, 0xfd6)
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'movdq2q ')
        assert_equal(myDisasm.infos.repr, 'movdq2q mm0, xmm0')

        # 66 0F D6 /r
        # MOVQ xmm2/m64, xmm1

        Buffer = '660fd620'.decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(myDisasm.infos.Instruction.Opcode, 0xfd6)
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'movq ')
        assert_equal(myDisasm.infos.repr, 'movq qword ptr [rax], xmm4')

        # VEX.128.66.0F.WIG D6 /r
        # VMOVQ xmm1/m64, xmm2

        myVEX = VEX('VEX.128.66.0F.WIG')
        Buffer = '{}d620'.format(myVEX.c4()).decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(myDisasm.infos.Instruction.Opcode, 0xd6)
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'vmovq ')
        assert_equal(myDisasm.infos.repr, 'vmovq dword ptr [r8], xmm12')

        # EVEX.128.66.0F.W1 D6 /r
        # VMOVQ xmm1/m64, xmm2

        myEVEX = EVEX('EVEX.128.66.0F.W1')
        Buffer = '{}d620'.format(myEVEX.prefix()).decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(myDisasm.infos.Instruction.Opcode, 0xd6)
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'vmovq ')
        assert_equal(myDisasm.infos.repr, 'vmovq dword ptr [r8], xmm28')
