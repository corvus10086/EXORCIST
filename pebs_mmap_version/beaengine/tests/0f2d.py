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

        # 66 0F 2d /r
        # cvtPD2PI mm, xmm/m128

        Buffer = '660f2d20'.decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(myDisasm.infos.Instruction.Opcode, 0xf2d)
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'cvtpd2pi ')
        assert_equal(myDisasm.infos.repr, 'cvtpd2pi mm4, xmmword ptr [rax]')

        # NP 0F 2d /r
        # cvtPS2PI mm, xmm/m64

        Buffer = '0f2d20'.decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(myDisasm.infos.Instruction.Opcode, 0xf2d)
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'cvtps2pi ')
        assert_equal(myDisasm.infos.repr, 'cvtps2pi mm4, qword ptr [rax]')

        # F2 0F 2d /r
        # cvtSD2SI r32, xmm1/m64

        Buffer = 'f20f2d20'.decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(myDisasm.infos.Instruction.Opcode, 0xf2d)
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'cvtsd2si ')
        assert_equal(myDisasm.infos.repr, 'cvtsd2si esp, qword ptr [rax]')

        Buffer = 'f20f2de0'.decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(myDisasm.infos.Instruction.Opcode, 0xf2d)
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'cvtsd2si ')
        assert_equal(myDisasm.infos.repr, 'cvtsd2si esp, xmm0')


        # F2 REX.W 0F 2d /r
        # cvtSD2SI r64, xmm1/m64

        myREX = REX()
        myREX.W = 1
        Buffer = 'f2{:02x}0f2d20'.format(myREX.byte()).decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(myDisasm.infos.Instruction.Opcode, 0xf2d)
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'cvtsd2si ')
        assert_equal(myDisasm.infos.repr, 'cvtsd2si rsp, qword ptr [rax]')

        # VEX.LIG.F2.0F.W0 2d /r 1
        # VcvtSD2SI r32, xmm1/m64

        myVEX = VEX('VEX.LIG.F2.0F.W0')
        Buffer = '{}2d10'.format(myVEX.c4()).decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(myDisasm.infos.Instruction.Opcode, 0x2d)
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'vcvtsd2si ')
        assert_equal(myDisasm.infos.repr, 'vcvtsd2si r10d, qword ptr [r8]')

        # VEX.LIG.F2.0F.W1 2d /r 1
        # VcvtSD2SI r64, xmm1/m64

        myVEX = VEX('VEX.LIG.F2.0F.W1')
        Buffer = '{}2d10'.format(myVEX.c4()).decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(myDisasm.infos.Instruction.Opcode, 0x2d)
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'vcvtsd2si ')
        assert_equal(myDisasm.infos.repr, 'vcvtsd2si r10, qword ptr [r8]')

        # EVEX.LIG.F2.0F.W0 2d /r
        # VcvtSD2SI r32, xmm1/m64{sae}

        myEVEX = EVEX('EVEX.LIG.F2.0F.W0')
        Buffer = '{}2d16'.format(myEVEX.prefix()).decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(myDisasm.infos.Instruction.Opcode, 0x2d)
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'vcvtsd2si ')
        assert_equal(myDisasm.infos.repr, 'vcvtsd2si r10w, qword ptr [r14]')

        # EVEX.LIG.F2.0F.W1 2d /r
        # VcvtSD2SI r64, xmm1/m64{sae}

        myEVEX = EVEX('EVEX.LIG.F2.0F.W1')
        Buffer = '{}2d16'.format(myEVEX.prefix()).decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(myDisasm.infos.Instruction.Opcode, 0x2d)
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'vcvtsd2si ')
        assert_equal(myDisasm.infos.repr, 'vcvtsd2si ebp, qword ptr [r14]')

        # F3 0F 2d /r
        # cvtSS2SI r32, xmm1/m32

        Buffer = 'f30f2d20'.decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(myDisasm.infos.Instruction.Opcode, 0xf2d)
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'cvtss2si ')
        assert_equal(myDisasm.infos.repr, 'cvtss2si esp, dword ptr [rax]')

        # F3 REX.W 0F 2d /r
        # cvtSS2SI r64, xmm1/m32

        myREX = REX()
        myREX.W = 1
        Buffer = 'f3{:02x}0f2d20'.format(myREX.byte()).decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(myDisasm.infos.Instruction.Opcode, 0xf2d)
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'cvtss2si ')
        assert_equal(myDisasm.infos.repr, 'cvtss2si rsp, dword ptr [rax]')

        # VEX.LIG.F3.0F.W0 2d /r 1
        # VcvtSS2SI r32, xmm1/m32

        myVEX = VEX('VEX.LIG.F3.0F.W0')
        Buffer = '{}2d10'.format(myVEX.c4()).decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(myDisasm.infos.Instruction.Opcode, 0x2d)
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'vcvtss2si ')
        assert_equal(myDisasm.infos.repr, 'vcvtss2si r10d, dword ptr [r8]')

        # VEX.LIG.F3.0F.W1 2d /r 1
        # VcvtSS2SI r64, xmm1/m32

        myVEX = VEX('VEX.LIG.F3.0F.W1')
        Buffer = '{}2d10'.format(myVEX.c4()).decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(myDisasm.infos.Instruction.Opcode, 0x2d)
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'vcvtss2si ')
        assert_equal(myDisasm.infos.repr, 'vcvtss2si r10, dword ptr [r8]')

        # EVEX.LIG.F3.0F.W0 2d /r
        # VcvtSS2SI r32, xmm1/m32{sae}

        myEVEX = EVEX('EVEX.LIG.F3.0F.W0')
        Buffer = '{}2d16'.format(myEVEX.prefix()).decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(myDisasm.infos.Instruction.Opcode, 0x2d)
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'vcvtss2si ')
        assert_equal(myDisasm.infos.repr, 'vcvtss2si r10w, dword ptr [r14]')

        # EVEX.LIG.F3.0F.W1 2d /r
        # VcvtSS2SI r64, xmm1/m32{sae}

        myEVEX = EVEX('EVEX.LIG.F3.0F.W1')
        Buffer = '{}2d16'.format(myEVEX.prefix()).decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(myDisasm.infos.Instruction.Opcode, 0x2d)
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'vcvtss2si ')
        assert_equal(myDisasm.infos.repr, 'vcvtss2si ebp, dword ptr [r14]')

        # VEX.vvvv and EVEX.vvvv are reserved and must be 1111b, otherwise instructions will #UD.

        myEVEX = EVEX('EVEX.LIG.F2.0F.W0')
        myEVEX.vvvv = 0b1000
        Buffer = '{}2d16'.format(myEVEX.prefix()).decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(myDisasm.infos.Instruction.Opcode, 0x2d)
        assert_equal(myDisasm.infos.Reserved_.ERROR_OPCODE, UD_)

        myVEX = VEX('VEX.LIG.F2.0F.W0')
        myVEX.vvvv = 0b1000
        Buffer = '{}2d16'.format(myVEX.c4()).decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(myDisasm.infos.Instruction.Opcode, 0x2d)
        assert_equal(myDisasm.infos.Reserved_.ERROR_OPCODE, UD_)
