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


        # NP 0F 7f /r
        # MOVQ mm/m64, mm

        Buffer = '0f7f20'.decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(myDisasm.infos.Instruction.Opcode, 0xf7f)
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'movq ')
        assert_equal(myDisasm.infos.repr, 'movq qword ptr [rax], mm4')

        # 66 0F 7f /r
        # MOVDQA xmm2/m128, xmm1

        Buffer = '660f7f20'.decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(myDisasm.infos.Instruction.Opcode, 0xf7f)
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'movdqa ')
        assert_equal(myDisasm.infos.repr, 'movdqa xmmword ptr [rax], xmm4')

        # VEX.128.66.0F.WIG 7f /r
        # VMOVDQA  xmm2/m128, xmm1

        myVEX = VEX('VEX.128.66.0F.WIG')
        Buffer = '{}7f20'.format(myVEX.c4()).decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(myDisasm.infos.Instruction.Opcode, 0x7f)
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'vmovdqa ')
        assert_equal(myDisasm.infos.repr, 'vmovdqa xmmword ptr [r8], xmm12')

        # VEX.256.66.0F.WIG 7f /r
        # VMOVDQA ymm2/m256, ymm1

        myVEX = VEX('VEX.256.66.0F.WIG')
        Buffer = '{}7f20'.format(myVEX.c4()).decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(myDisasm.infos.Instruction.Opcode, 0x7f)
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'vmovdqa ')
        assert_equal(myDisasm.infos.repr, 'vmovdqa ymmword ptr [r8], ymm12')

        # EVEX.128.66.0F.W0 7f /r
        # VMOVDQA32 xmm2/m128, xmm1 {k1}{z}

        myEVEX = EVEX('EVEX.128.66.0F.W0')
        Buffer = '{}7f20'.format(myEVEX.prefix()).decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(myDisasm.infos.Instruction.Opcode, 0x7f)
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'vmovdqa32 ')
        assert_equal(myDisasm.infos.repr, 'vmovdqa32 xmmword ptr [r8], xmm28')

        # EVEX.256.66.0F.W0 7f /r
        # VMOVDQA32 ymm2/m256, ymm1 {k1}{z}

        myEVEX = EVEX('EVEX.256.66.0F.W0')
        Buffer = '{}7f20'.format(myEVEX.prefix()).decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(myDisasm.infos.Instruction.Opcode, 0x7f)
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'vmovdqa32 ')
        assert_equal(myDisasm.infos.repr, 'vmovdqa32 ymmword ptr [r8], ymm28')

        # EVEX.512.66.0F.W0 7f /r
        # VMOVDQA32 zmm2/m512, zmm1 {k1}{z}

        myEVEX = EVEX('EVEX.512.66.0F.W0')
        Buffer = '{}7f20'.format(myEVEX.prefix()).decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(myDisasm.infos.Instruction.Opcode, 0x7f)
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'vmovdqa32 ')
        assert_equal(myDisasm.infos.repr, 'vmovdqa32 zmmword ptr [r8], zmm28')

        # EVEX.128.66.0F.W1 7f /r
        # VMOVDQA64 xmm2/m128, xmm1 {k1}{z}

        myEVEX = EVEX('EVEX.128.66.0F.W1')
        Buffer = '{}7f20'.format(myEVEX.prefix()).decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(myDisasm.infos.Instruction.Opcode, 0x7f)
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'vmovdqa64 ')
        assert_equal(myDisasm.infos.repr, 'vmovdqa64 xmmword ptr [r8], xmm28')

        # EVEX.256.66.0F.W1 7f /r
        # VMOVDQA64 ymm2/m256, ymm1 {k1}{z}

        myEVEX = EVEX('EVEX.256.66.0F.W1')
        Buffer = '{}7f20'.format(myEVEX.prefix()).decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(myDisasm.infos.Instruction.Opcode, 0x7f)
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'vmovdqa64 ')
        assert_equal(myDisasm.infos.repr, 'vmovdqa64 ymmword ptr [r8], ymm28')

        # EVEX.512.66.0F.W1 7f /r
        # VMOVDQA64 zmm2/m512, zmm1 {k1}{z}

        myEVEX = EVEX('EVEX.512.66.0F.W1')
        Buffer = '{}7f20'.format(myEVEX.prefix()).decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(myDisasm.infos.Instruction.Opcode, 0x7f)
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'vmovdqa64 ')
        assert_equal(myDisasm.infos.repr, 'vmovdqa64 zmmword ptr [r8], zmm28')

        # F3 0F 7f /r
        # MOVDQU xmm2/m128, xmm1

        Buffer = 'f30f7f20'.decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(myDisasm.infos.Instruction.Opcode, 0xf7f)
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'movdqu ')
        assert_equal(myDisasm.infos.repr, 'movdqu xmmword ptr [rax], xmm4')

        # VEX.128.F3.0F.WIG 7f /r
        # VMOVDQU xmm2/m128, xmm1

        myVEX = VEX('VEX.128.F3.0F.WIG')
        Buffer = '{}7f20'.format(myVEX.c4()).decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(myDisasm.infos.Instruction.Opcode, 0x7f)
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'vmovdqu ')
        assert_equal(myDisasm.infos.repr, 'vmovdqu xmmword ptr [r8], xmm12')

        # VEX.256.F3.0F.WIG 7f /r
        # VMOVDQU ymm2/m256, ymm1

        myVEX = VEX('VEX.256.F3.0F.WIG')
        Buffer = '{}7f20'.format(myVEX.c4()).decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(myDisasm.infos.Instruction.Opcode, 0x7f)
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'vmovdqu ')
        assert_equal(myDisasm.infos.repr, 'vmovdqu ymmword ptr [r8], ymm12')

        # EVEX.128.F3.0F.W0 7f /r
        # VMOVDQU32 xmm2/mm128, xmm1 {k1}{z}

        myEVEX = EVEX('EVEX.128.F3.0F.W0')
        Buffer = '{}7f20'.format(myEVEX.prefix()).decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(myDisasm.infos.Instruction.Opcode, 0x7f)
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'vmovdqu32 ')
        assert_equal(myDisasm.infos.repr, 'vmovdqu32 xmmword ptr [r8], xmm28')

        # EVEX.256.F3.0F.W0 7f /r
        # VMOVDQU32 ymm2/m256, ymm1 {k1}{z}

        myEVEX = EVEX('EVEX.256.F3.0F.W0')
        Buffer = '{}7f20'.format(myEVEX.prefix()).decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(myDisasm.infos.Instruction.Opcode, 0x7f)
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'vmovdqu32 ')
        assert_equal(myDisasm.infos.repr, 'vmovdqu32 ymmword ptr [r8], ymm28')

        # EVEX.512.F3.0F.W0 7f /r
        # VMOVDQU32 zmm2/m512, zmm1 {k1}{z}

        myEVEX = EVEX('EVEX.512.F3.0F.W0')
        Buffer = '{}7f20'.format(myEVEX.prefix()).decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(myDisasm.infos.Instruction.Opcode, 0x7f)
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'vmovdqu32 ')
        assert_equal(myDisasm.infos.repr, 'vmovdqu32 zmmword ptr [r8], zmm28')

        # EVEX.128.F3.0F.W1 7f /r
        # VMOVDQU64 xmm2/m128, xmm1 {k1}{z}

        myEVEX = EVEX('EVEX.128.F3.0F.W1')
        Buffer = '{}7f20'.format(myEVEX.prefix()).decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(myDisasm.infos.Instruction.Opcode, 0x7f)
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'vmovdqu64 ')
        assert_equal(myDisasm.infos.repr, 'vmovdqu64 xmmword ptr [r8], xmm28')

        # EVEX.256.F3.0F.W1 7f /r
        # VMOVDQU64 ymm2/m256, ymm1 {k1}{z}

        myEVEX = EVEX('EVEX.256.F3.0F.W1')
        Buffer = '{}7f20'.format(myEVEX.prefix()).decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(myDisasm.infos.Instruction.Opcode, 0x7f)
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'vmovdqu64 ')
        assert_equal(myDisasm.infos.repr, 'vmovdqu64 ymmword ptr [r8], ymm28')

        # EVEX.512.F3.0F.W1 7f /r
        # VMOVDQU64 zmm2/m512, zmm1 {k1}{z}

        myEVEX = EVEX('EVEX.512.F3.0F.W1')
        Buffer = '{}7f20'.format(myEVEX.prefix()).decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(myDisasm.infos.Instruction.Opcode, 0x7f)
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'vmovdqu64 ')
        assert_equal(myDisasm.infos.repr, 'vmovdqu64 zmmword ptr [r8], zmm28')

        # EVEX.128.F2.0F.W0 7f /r
        # VMOVDQU8 xmm2/m128, xmm1 {k1}{z}

        myEVEX = EVEX('EVEX.128.F2.0F.W0')
        Buffer = '{}7f20'.format(myEVEX.prefix()).decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(myDisasm.infos.Instruction.Opcode, 0x7f)
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'vmovdqu8 ')
        assert_equal(myDisasm.infos.repr, 'vmovdqu8 xmmword ptr [r8], xmm28')

        # EVEX.256.F2.0F.W0 7f /r
        # VMOVDQU8 ymm2/m256, ymm1 {k1}{z}

        myEVEX = EVEX('EVEX.256.F2.0F.W0')
        Buffer = '{}7f20'.format(myEVEX.prefix()).decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(myDisasm.infos.Instruction.Opcode, 0x7f)
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'vmovdqu8 ')
        assert_equal(myDisasm.infos.repr, 'vmovdqu8 ymmword ptr [r8], ymm28')

        # EVEX.512.F2.0F.W0 7f /r
        # VMOVDQU8 zmm2/m512, zmm1 {k1}{z}

        myEVEX = EVEX('EVEX.512.F2.0F.W0')
        Buffer = '{}7f20'.format(myEVEX.prefix()).decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(myDisasm.infos.Instruction.Opcode, 0x7f)
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'vmovdqu8 ')
        assert_equal(myDisasm.infos.repr, 'vmovdqu8 zmmword ptr [r8], zmm28')

        # EVEX.128.F2.0F.W1 7f /r
        # VMOVDQU16 xmm2/m128, xmm1 {k1}{z}

        myEVEX = EVEX('EVEX.128.F2.0F.W1')
        Buffer = '{}7f20'.format(myEVEX.prefix()).decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(myDisasm.infos.Instruction.Opcode, 0x7f)
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'vmovdqu16 ')
        assert_equal(myDisasm.infos.repr, 'vmovdqu16 xmmword ptr [r8], xmm28')

        # EVEX.256.F2.0F.W1 7f /r
        # VMOVDQU16 ymm2/m256, ymm1 {k1}{z}

        myEVEX = EVEX('EVEX.256.F2.0F.W1')
        Buffer = '{}7f20'.format(myEVEX.prefix()).decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(myDisasm.infos.Instruction.Opcode, 0x7f)
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'vmovdqu16 ')
        assert_equal(myDisasm.infos.repr, 'vmovdqu16 ymmword ptr [r8], ymm28')

        # EVEX.512.F2.0F.W1 7f /r
        # VMOVDQU16 zmm2/m512, zmm1 {k1}{z}

        myEVEX = EVEX('EVEX.512.F2.0F.W1')
        Buffer = '{}7f20'.format(myEVEX.prefix()).decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(myDisasm.infos.Instruction.Opcode, 0x7f)
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'vmovdqu16 ')
        assert_equal(myDisasm.infos.repr, 'vmovdqu16 zmmword ptr [r8], zmm28')
