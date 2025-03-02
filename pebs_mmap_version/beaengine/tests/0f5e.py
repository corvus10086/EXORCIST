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

        # 66 0F 5e /r
        # divpd xmm1, xmm2/m128

        Buffer = '660f5e90'.decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(myDisasm.infos.Instruction.Opcode, 0xf5e)
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'divpd ')
        assert_equal(myDisasm.infos.repr, 'divpd xmm2, xmmword ptr [rax+00000000h]')

        # VEX.NDS.128.66.0F.WIG 5e /r
        # Vdivpd xmm1,xmm2, xmm3/m128

        myVEX = VEX('VEX.NDS.128.66.0F.WIG')
        Buffer = '{}5e90'.format(myVEX.c4()).decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(myDisasm.infos.Instruction.Opcode, 0x5e)
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'vdivpd ')
        assert_equal(myDisasm.infos.repr, 'vdivpd xmm10, xmm15, xmmword ptr [r8+00000000h]')

        # VEX.NDS.256.66.0F.WIG 5e /r
        # Vdivpd ymm1, ymm2, ymm3/m256

        myVEX = VEX('VEX.NDS.256.66.0F.WIG')
        Buffer = '{}5e90'.format(myVEX.c4()).decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(myDisasm.infos.Instruction.Opcode, 0x5e)
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'vdivpd ')
        assert_equal(myDisasm.infos.repr, 'vdivpd ymm10, ymm15, ymmword ptr [r8+00000000h]')

        # EVEX.NDS.128.66.0F.W1 5e /r
        # Vdivpd xmm1 {k1}{z}, xmm2, xmm3/m128/m64bcst

        myEVEX = EVEX('EVEX.NDS.128.66.0F.W1')
        Buffer = '{}5e90'.format(myEVEX.prefix()).decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(myDisasm.infos.Instruction.Opcode, 0x5e)
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'vdivpd ')
        assert_equal(myDisasm.infos.repr, 'vdivpd xmm26, xmm31, xmmword ptr [r8+00000000h]')

        # EVEX.NDS.256.66.0F.W1 5e /r
        # Vdivpd ymm1 {k1}{z}, ymm2, ymm3/m256/m64bcst

        myEVEX = EVEX('EVEX.NDS.256.66.0F.W1')
        Buffer = '{}5e90'.format(myEVEX.prefix()).decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(myDisasm.infos.Instruction.Opcode, 0x5e)
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'vdivpd ')
        assert_equal(myDisasm.infos.repr, 'vdivpd ymm26, ymm31, ymmword ptr [r8+00000000h]')

        # EVEX.NDS.512.66.0F.W1 5e /r
        # Vdivpd zmm1 {k1}{z}, zmm2, zmm3/m512/m64bcst{er}

        myEVEX = EVEX('EVEX.NDS.512.66.0F.W1')
        Buffer = '{}5e90'.format(myEVEX.prefix()).decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(myDisasm.infos.Instruction.Opcode, 0x5e)
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'vdivpd ')
        assert_equal(myDisasm.infos.repr, 'vdivpd zmm26, zmm31, zmmword ptr [r8+00000000h]')

        # NP 0F 5e /r
        # divps xmm1, xmm2/m128

        Buffer = '0f5e90'.decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(myDisasm.infos.Instruction.Opcode, 0xf5e)
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'divps ')
        assert_equal(myDisasm.infos.repr, 'divps xmm2, xmmword ptr [rax+00000000h]')

        # VEX.NDS.128.0F.WIG 5e /r
        # Vdivps xmm1,xmm2, xmm3/m128

        myVEX = VEX('VEX.NDS.128.0F.WIG')
        Buffer = '{}5e90'.format(myVEX.c4()).decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(myDisasm.infos.Instruction.Opcode, 0x5e)
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'vdivps ')
        assert_equal(myDisasm.infos.repr, 'vdivps xmm10, xmm15, xmmword ptr [r8+00000000h]')

        # VEX.NDS.256.0F.WIG 5e /r
        # Vdivps ymm1, ymm2, ymm3/m256

        myVEX = VEX('VEX.NDS.256.0F.WIG')
        Buffer = '{}5e90'.format(myVEX.c4()).decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(myDisasm.infos.Instruction.Opcode, 0x5e)
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'vdivps ')
        assert_equal(myDisasm.infos.repr, 'vdivps ymm10, ymm15, ymmword ptr [r8+00000000h]')

        # EVEX.NDS.128.0F.W0 5e /r
        # Vdivps xmm1 {k1}{z}, xmm2, xmm3/m128/m32bcst

        myEVEX = EVEX('EVEX.NDS.128.0F.W0')
        Buffer = '{}5e90'.format(myEVEX.prefix()).decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(myDisasm.infos.Instruction.Opcode, 0x5e)
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'vdivps ')
        assert_equal(myDisasm.infos.repr, 'vdivps xmm26, xmm31, xmmword ptr [r8+00000000h]')

        # EVEX.NDS.256.0F.W0 5e /r
        # Vdivps ymm1 {k1}{z}, ymm2, ymm3/m256/m32bcst

        myEVEX = EVEX('EVEX.NDS.256.0F.W0')
        Buffer = '{}5e90'.format(myEVEX.prefix()).decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(myDisasm.infos.Instruction.Opcode, 0x5e)
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'vdivps ')
        assert_equal(myDisasm.infos.repr, 'vdivps ymm26, ymm31, ymmword ptr [r8+00000000h]')

        # EVEX.NDS.512.0F.W0 5e /r
        # Vdivps zmm1 {k1}{z}, zmm2, zmm3/m512/m32bcst {er}

        myEVEX = EVEX('EVEX.NDS.512.0F.W0')
        Buffer = '{}5e90'.format(myEVEX.prefix()).decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(myDisasm.infos.Instruction.Opcode, 0x5e)
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'vdivps ')
        assert_equal(myDisasm.infos.repr, 'vdivps zmm26, zmm31, zmmword ptr [r8+00000000h]')

        # F2 0F 5e /r
        # divsd xmm1, xmm2/m64

        Buffer = 'f20f5e90'.decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(myDisasm.infos.Instruction.Opcode, 0xf5e)
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'divsd ')
        assert_equal(myDisasm.infos.repr, 'divsd xmm2, qword ptr [rax+00000000h]')

        # VEX.NDS.LIG.F2.0F.WIG 5e /r
        # Vdivsd xmm1, xmm2, xmm3/m64

        myVEX = VEX('VEX.NDS.LIG.F2.0F.WIG')
        Buffer = '{}5e90'.format(myVEX.c4()).decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(myDisasm.infos.Instruction.Opcode, 0x5e)
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'vdivsd ')
        assert_equal(myDisasm.infos.repr, 'vdivsd xmm10, xmm15, qword ptr [r8+00000000h]')

        # EVEX.NDS.LIG.F2.0F.W1 5e /r
        # Vdivsd xmm1 {k1}{z}, xmm2, xmm3/m64{er}

        myEVEX = EVEX('EVEX.NDS.LIG.F2.0F.W1')
        Buffer = '{}5e90'.format(myEVEX.prefix()).decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(myDisasm.infos.Instruction.Opcode, 0x5e)
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'vdivsd ')
        assert_equal(myDisasm.infos.repr, 'vdivsd xmm26, xmm31, qword ptr [r8+00000000h]')

        # F3 0F 5e /r
        # divss xmm1, xmm2/m32

        Buffer = 'f30f5e90'.decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(myDisasm.infos.Instruction.Opcode, 0xf5e)
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'divss ')
        assert_equal(myDisasm.infos.repr, 'divss xmm2, dword ptr [rax+00000000h]')

        # VEX.NDS.LIG.F3.0F.WIG 5e /r
        # Vdivss xmm1,xmm2, xmm3/m32

        myVEX = VEX('VEX.NDS.LIG.F3.0F.WIG')
        Buffer = '{}5e90'.format(myVEX.c4()).decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(myDisasm.infos.Instruction.Opcode, 0x5e)
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'vdivss ')
        assert_equal(myDisasm.infos.repr, 'vdivss xmm10, xmm15, dword ptr [r8+00000000h]')

        # EVEX.NDS.LIG.F3.0F.W0 5e /r
        # Vdivss xmm1{k1}{z}, xmm2, xmm3/m32{er}

        myEVEX = EVEX('EVEX.NDS.LIG.F3.0F.W0')
        Buffer = '{}5e90'.format(myEVEX.prefix()).decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(myDisasm.infos.Instruction.Opcode, 0x5e)
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'vdivss ')
        assert_equal(myDisasm.infos.repr, 'vdivss xmm26, xmm31, dword ptr [r8+00000000h]')
