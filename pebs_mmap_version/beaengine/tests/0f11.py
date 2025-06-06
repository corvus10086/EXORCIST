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

        # F2 0F 11 /r
        # MOVSD xmm1, xmm2

        Buffer = 'f20f11e0'.decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(hex(myDisasm.infos.Instruction.Opcode), '0xf11')
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'movsd ')
        assert_equal(myDisasm.infos.repr, 'movsd xmm0, xmm4')

        # F2 0F 11 /r
        # MOVSD m64, xmm1
        Buffer = 'f20f1190'.decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(hex(myDisasm.infos.Instruction.Opcode), '0xf11')
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'movsd ')
        assert_equal(myDisasm.infos.repr, 'movsd qword ptr [rax+00000000h], xmm2')

        # VEX.NDS.LIG.F2.0F.WIG 11 /r
        # VMOVSD xmm1, xmm2, xmm3

        myVEX = VEX('VEX.NDS.LIG.F2.0F.WIG')
        Buffer = '{}11e0'.format(myVEX.c4()).decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(hex(myDisasm.infos.Instruction.Opcode), '0x11')
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'vmovsd ')
        assert_equal(myDisasm.infos.repr, 'vmovsd xmm8, xmm15, xmm12')

        # VEX.LIG.F2.0F.WIG 11 /r
        # VMOVSD m64, xmm1

        myVEX = VEX('VEX.LIG.F2.0F.WIG')
        myVEX.vvvv = 0b1111
        Buffer = '{}1190'.format(myVEX.c4()).decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(hex(myDisasm.infos.Instruction.Opcode), '0x11')
        assert_equal(myDisasm.infos.Reserved_.VEX.vvvv, 0xF)
        assert_equal(myDisasm.infos.Reserved_.VEX.pp, 0x3)
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'vmovsd ')
        assert_equal(myDisasm.infos.repr, 'vmovsd qword ptr [r8+00000000h], xmm10')

        # EVEX.NDS.LIG.F2.0F.W1 11 /r
        # VMOVSD xmm3, xmm2, xmm1 {k1}{z}

        myEVEX = EVEX('EVEX.NDS.LIG.F2.0F.W1')
        Buffer = '{}1190'.format(myEVEX.prefix()).decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(hex(myDisasm.infos.Instruction.Opcode), '0x11')
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'vmovsd ')
        assert_equal(myDisasm.infos.repr, 'vmovsd xmmword ptr [r8+00000000h], xmm31, xmm26')

        # EVEX.LIG.F2.0F.W1 11 /r
        # VMOVSD m64, xmm1 {k1}{z}

        myEVEX = EVEX('EVEX.LIG.F2.0F.W1')
        myEVEX.vvvv = 0b1111
        Buffer = '{}1190'.format(myEVEX.prefix()).decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(hex(myDisasm.infos.Instruction.Opcode), '0x11')
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'vmovsd ')
        assert_equal(myDisasm.infos.Reserved_.EVEX.vvvv, 0xF)
        assert_equal(myDisasm.infos.Reserved_.VEX.vvvv, 0xF)
        assert_equal(myDisasm.infos.Reserved_.VEX.pp, 0x3)
        assert_equal(myDisasm.infos.repr, 'vmovsd qword ptr [r8+00000000h], xmm26')

        # F3 0F 11 /r
        # MOVSS xmm1, xmm2

        Buffer = 'f30f11e0'.decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(hex(myDisasm.infos.Instruction.Opcode), '0xf11')
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'movss ')
        assert_equal(myDisasm.infos.repr, 'movss xmm0, xmm4')

        # F3 0F 11 /r
        # MOVSS m32, xmm1

        Buffer = 'f30f1190'.decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(hex(myDisasm.infos.Instruction.Opcode), '0xf11')
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'movss ')
        assert_equal(myDisasm.infos.repr, 'movss dword ptr [rax+00000000h], xmm2')

        # VEX.NDS.LIG.F3.0F.WIG 11 /r
        # VMOVSS xmm1, xmm2, xmm3

        myVEX = VEX('VEX.NDS.LIG.F3.0F.WIG')
        Buffer = '{}11e0'.format(myVEX.c4()).decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(hex(myDisasm.infos.Instruction.Opcode), '0x11')
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'vmovss ')
        assert_equal(myDisasm.infos.repr, 'vmovss xmm8, xmm15, xmm12')

        # VEX.LIG.F3.0F.WIG 11 /r
        # VMOVSS m32, xmm1

        myVEX = VEX('VEX.LIG.F3.0F.WIG')
        Buffer = '{}1190'.format(myVEX.c4()).decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(hex(myDisasm.infos.Instruction.Opcode), '0x11')
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'vmovss ')
        assert_equal(myDisasm.infos.repr, 'vmovss dword ptr [r8+00000000h], xmm10')

        # EVEX.NDS.LIG.F3.0F.W0 11 /r
        # VMOVSS xmm3, xmm2, xmm1 {k1}{z}

        myEVEX = EVEX('EVEX.NDS.LIG.F3.0F.W1')
        Buffer = '{}11e0'.format(myEVEX.prefix()).decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(hex(myDisasm.infos.Instruction.Opcode), '0x11')
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'vmovss ')
        assert_equal(myDisasm.infos.repr, 'vmovss xmm24, xmm31, xmm28')

        # EVEX.LIG.F3.0F.W0 11 /r
        # VMOVSS  m32, xmm1 {k1}{z}

        myEVEX = EVEX('EVEX.LIG.F3.0F.W1')
        myEVEX.vvvv = 0b1111
        Buffer = '{}1190'.format(myEVEX.prefix()).decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(hex(myDisasm.infos.Instruction.Opcode), '0x11')
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'vmovss ')
        assert_equal(myDisasm.infos.repr, 'vmovss dword ptr [r8+00000000h], xmm26')

        # 66 0F 11 /r
        # MOVUPD xmm2/m128, xmm1

        Buffer = '660f1190'.decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(hex(myDisasm.infos.Instruction.Opcode), '0xf11')
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'movupd ')
        assert_equal(myDisasm.infos.repr, 'movupd xmmword ptr [rax+00000000h], xmm2')

        # VEX.128.66.0F.WIG 11 /r
        # VMOVUPD xmm2/m128, xmm1

        myVEX = VEX('VEX.128.66.0F.WIG')
        Buffer = '{}1190'.format(myVEX.c4()).decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(hex(myDisasm.infos.Instruction.Opcode), '0x11')
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'vmovupd ')
        assert_equal(myDisasm.infos.repr, 'vmovupd xmmword ptr [r8+00000000h], xmm10')

        # VEX.256.66.0F.WIG 11 /r
        myVEX = VEX('VEX.256.66.0F.WIG')
        Buffer = '{}1190'.format(myVEX.c4()).decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(hex(myDisasm.infos.Instruction.Opcode), '0x11')
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'vmovupd ')
        assert_equal(myDisasm.infos.repr, 'vmovupd ymmword ptr [r8+00000000h], ymm10')

        # EVEX.128.66.0F.W1 11 /r
        # VMOVUPD xmm2/m128, xmm1 {k1}{z}

        myEVEX = EVEX('EVEX.128.66.0F.W1')
        Buffer = '{}1190'.format(myEVEX.prefix()).decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(hex(myDisasm.infos.Instruction.Opcode), '0x11')
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'vmovupd ')
        assert_equal(myDisasm.infos.repr, 'vmovupd xmmword ptr [r8+00000000h], xmm26')

        # EVEX.256.66.0F.W1 11 /r
        # VMOVUPD ymm2/m256, ymm1 {k1}{z}

        myEVEX = EVEX('EVEX.256.66.0F.W1')
        Buffer = '{}1190'.format(myEVEX.prefix()).decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(hex(myDisasm.infos.Instruction.Opcode), '0x11')
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'vmovupd ')
        assert_equal(myDisasm.infos.repr, 'vmovupd ymmword ptr [r8+00000000h], ymm26')

        # EVEX.512.66.0F.W1 11 /r
        # VMOVUPD zmm2/m512, zmm1 {k1}{z}

        myEVEX = EVEX('EVEX.512.66.0F.W1')
        Buffer = '{}1190'.format(myEVEX.prefix()).decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(hex(myDisasm.infos.Instruction.Opcode), '0x11')
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'vmovupd ')
        assert_equal(myDisasm.infos.repr, 'vmovupd zmmword ptr [r8+00000000h], zmm26')


        # 0F 11 /r
        # MOVUPS xmm2/m128, xmm1

        Buffer = '0f1190'.decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(hex(myDisasm.infos.Instruction.Opcode), '0xf11')
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'movups ')
        assert_equal(myDisasm.infos.repr, 'movups xmmword ptr [rax+00000000h], xmm2')

        # VEX.128.0F.WIG 11 /r
        # VMOVUPD xmm2/m128, xmm1

        myVEX = VEX('VEX.128.0F.WIG')
        Buffer = '{}1190'.format(myVEX.c4()).decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(hex(myDisasm.infos.Instruction.Opcode), '0x11')
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'vmovups ')
        assert_equal(myDisasm.infos.repr, 'vmovups xmmword ptr [r8+00000000h], xmm10')

        # VEX.256.0F.WIG 11 /r
        myVEX = VEX('VEX.256.0F.WIG')
        Buffer = '{}1190'.format(myVEX.c4()).decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(hex(myDisasm.infos.Instruction.Opcode), '0x11')
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'vmovups ')
        assert_equal(myDisasm.infos.repr, 'vmovups ymmword ptr [r8+00000000h], ymm10')

        # EVEX.128.0F.W1 11 /r
        # VMOVUPD xmm2/m128, xmm1 {k1}{z}

        myEVEX = EVEX('EVEX.128.0F.W1')
        Buffer = '{}1190'.format(myEVEX.prefix()).decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(hex(myDisasm.infos.Instruction.Opcode), '0x11')
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'vmovups ')
        assert_equal(myDisasm.infos.repr, 'vmovups xmmword ptr [r8+00000000h], xmm26')

        # EVEX.256.0F.W1 11 /r
        # VMOVUPD ymm2/m256, ymm1 {k1}{z}

        myEVEX = EVEX('EVEX.256.0F.W1')
        Buffer = '{}1190'.format(myEVEX.prefix()).decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(hex(myDisasm.infos.Instruction.Opcode), '0x11')
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'vmovups ')
        assert_equal(myDisasm.infos.repr, 'vmovups ymmword ptr [r8+00000000h], ymm26')

        # EVEX.512.0F.W1 11 /r
        # VMOVUPD zmm2/m512, zmm1 {k1}{z}

        myEVEX = EVEX('EVEX.512.0F.W1')
        Buffer = '{}1190'.format(myEVEX.prefix()).decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(hex(myDisasm.infos.Instruction.Opcode), '0x11')
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'vmovups ')
        assert_equal(myDisasm.infos.repr, 'vmovups zmmword ptr [r8+00000000h], zmm26')
