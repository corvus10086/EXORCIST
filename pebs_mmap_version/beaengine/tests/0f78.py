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

        # NP 0F 78
        # VMREAD r/m64, r64

        Buffer = '0f7820'.decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(hex(myDisasm.infos.Instruction.Opcode), '0xf78')
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'vmread ')
        assert_equal(myDisasm.infos.repr, 'vmread qword ptr [rax], rsp')

        # EVEX.128.0F.W0 78 /r
        # vcvttPS2UDQ xmm1 {k1}{z}, xmm2/m128/m32bcst

        myEVEX = EVEX('EVEX.128.0F.W0')
        Buffer = '{}7820'.format(myEVEX.prefix()).decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(myDisasm.infos.Instruction.Opcode, 0x78)
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'vcvttps2udq ')
        assert_equal(myDisasm.infos.repr, 'vcvttps2udq xmm28, xmmword ptr [r8]')

        # EVEX.256.0F.W0 78 /r
        # vcvtttPS2UDQ ymm1 {k1}{z}, ymm2/m256/m32bcst

        myEVEX = EVEX('EVEX.256.0F.W0')
        Buffer = '{}7820'.format(myEVEX.prefix()).decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(myDisasm.infos.Instruction.Opcode, 0x78)
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'vcvttps2udq ')
        assert_equal(myDisasm.infos.repr, 'vcvttps2udq ymm28, ymmword ptr [r8]')

        # EVEX.512.0F.W0 78 /r
        # vcvttPS2UDQ zmm1 {k1}{z}, zmm2/m512/m32bcst{er}

        myEVEX = EVEX('EVEX.512.0F.W0')
        Buffer = '{}7820'.format(myEVEX.prefix()).decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(myDisasm.infos.Instruction.Opcode, 0x78)
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'vcvttps2udq ')
        assert_equal(myDisasm.infos.repr, 'vcvttps2udq zmm28, zmmword ptr [r8]')

        # EVEX.128.0F.W1 78 /r
        # vcvttPD2UDQ xmm1 {k1}{z}, xmm2/m128/m64bcst

        myEVEX = EVEX('EVEX.128.0F.W1')
        Buffer = '{}7820'.format(myEVEX.prefix()).decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(myDisasm.infos.Instruction.Opcode, 0x78)
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'vcvttpd2udq ')
        assert_equal(myDisasm.infos.repr, 'vcvttpd2udq xmm28, xmmword ptr [r8]')

        # EVEX.256.0F.W1 78 /r
        # vcvttPD2UDQ xmm1 {k1}{z}, ymm2/m256/m64bcst

        myEVEX = EVEX('EVEX.256.0F.W1')
        Buffer = '{}7820'.format(myEVEX.prefix()).decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(myDisasm.infos.Instruction.Opcode, 0x78)
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'vcvttpd2udq ')
        assert_equal(myDisasm.infos.repr, 'vcvttpd2udq ymm28, ymmword ptr [r8]')

        # EVEX.512.0F.W1 78 /r
        # vcvttPD2UDQ ymm1 {k1}{z}, zmm2/m512/m64bcst{er}

        myEVEX = EVEX('EVEX.512.0F.W1')
        Buffer = '{}7820'.format(myEVEX.prefix()).decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(myDisasm.infos.Instruction.Opcode, 0x78)
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'vcvttpd2udq ')
        assert_equal(myDisasm.infos.repr, 'vcvttpd2udq zmm28, zmmword ptr [r8]')

        # EVEX.128.66.0F.W0 78 /r
        # vcvttPS2UQQ xmm1 {k1}{z}, xmm2/m64/m32bcst

        myEVEX = EVEX('EVEX.128.66.0F.W0')
        Buffer = '{}7820'.format(myEVEX.prefix()).decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(myDisasm.infos.Instruction.Opcode, 0x78)
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'vcvttps2uqq ')
        assert_equal(myDisasm.infos.repr, 'vcvttps2uqq xmm28, qword ptr [r8]')

        # EVEX.256.66.0F.W0 78 /r
        # vcvttPS2UQQ ymm1 {k1}{z}, xmm2/m128/m32bcst

        myEVEX = EVEX('EVEX.256.66.0F.W0')
        Buffer = '{}7820'.format(myEVEX.prefix()).decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(myDisasm.infos.Instruction.Opcode, 0x78)
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'vcvttps2uqq ')
        assert_equal(myDisasm.infos.repr, 'vcvttps2uqq ymm28, xmmword ptr [r8]')

        # EVEX.512.66.0F.W0 78 /r
        # vcvttPS2UQQ zmm1 {k1}{z}, ymm2/m256/m32bcst{er}

        myEVEX = EVEX('EVEX.512.66.0F.W0')
        Buffer = '{}7820'.format(myEVEX.prefix()).decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(myDisasm.infos.Instruction.Opcode, 0x78)
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'vcvttps2uqq ')
        assert_equal(myDisasm.infos.repr, 'vcvttps2uqq zmm28, ymmword ptr [r8]')

        # EVEX.128.66.0F.W1 78 /r
        # vcvttPD2UQQ xmm1 {k1}{z}, xmm2/m128/m64bcst

        myEVEX = EVEX('EVEX.128.66.0F.W1')
        Buffer = '{}7820'.format(myEVEX.prefix()).decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(myDisasm.infos.Instruction.Opcode, 0x78)
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'vcvttpd2uqq ')
        assert_equal(myDisasm.infos.repr, 'vcvttpd2uqq xmm28, xmmword ptr [r8]')

        # EVEX.256.66.0F.W1 78 /r
        # vcvttPD2UQQ ymm1 {k1}{z}, ymm2/m256/m64bcst

        myEVEX = EVEX('EVEX.256.66.0F.W1')
        Buffer = '{}7820'.format(myEVEX.prefix()).decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(myDisasm.infos.Instruction.Opcode, 0x78)
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'vcvttpd2uqq ')
        assert_equal(myDisasm.infos.repr, 'vcvttpd2uqq ymm28, ymmword ptr [r8]')

        # EVEX.512.66.0F.W1 78 /r
        # vcvttPD2UQQ zmm1 {k1}{z}, zmm2/m512/m64bcst{er}

        myEVEX = EVEX('EVEX.512.66.0F.W1')
        Buffer = '{}7820'.format(myEVEX.prefix()).decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(myDisasm.infos.Instruction.Opcode, 0x78)
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'vcvttpd2uqq ')
        assert_equal(myDisasm.infos.repr, 'vcvttpd2uqq zmm28, zmmword ptr [r8]')

        # EVEX.LIG.F3.0F.W0 78 /r
        # vcvttSS2USI r32, xmm1/m32{er}

        myEVEX = EVEX('EVEX.LIG.F3.0F.W0')
        Buffer = '{}7820'.format(myEVEX.prefix()).decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(myDisasm.infos.Instruction.Opcode, 0x78)
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'vcvttss2usi ')
        assert_equal(myDisasm.infos.repr, 'vcvttss2usi r12w, dword ptr [r8]')

        myEVEX = EVEX('EVEX.LIG.F3.0F.W0')
        Buffer = '{}78c0'.format(myEVEX.prefix()).decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(myDisasm.infos.Instruction.Opcode, 0x78)
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'vcvttss2usi ')
        assert_equal(myDisasm.infos.repr, 'vcvttss2usi r8w, xmm24')

        # EVEX.LIG.F3.0F.W1 78 /r
        # vcvttSS2USI r64, xmm1/m32{er}

        myEVEX = EVEX('EVEX.LIG.F3.0F.W1')
        Buffer = '{}7820'.format(myEVEX.prefix()).decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(myDisasm.infos.Instruction.Opcode, 0x78)
        assert_equal(myDisasm.infos.Reserved_.EVEX.W, 1)
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'vcvttss2usi ')
        assert_equal(myDisasm.infos.repr, 'vcvttss2usi esi, dword ptr [r8]')

        # EVEX.LIG.F2.0F.W0 78 /r
        # vcvttSD2USI r32, xmm1/m64{er}

        myEVEX = EVEX('EVEX.LIG.F3.0F.W1')
        Buffer = '{}7820'.format(myEVEX.prefix()).decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(myDisasm.infos.Instruction.Opcode, 0x78)
        assert_equal(myDisasm.infos.Reserved_.EVEX.W, 1)
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'vcvttss2usi ')
        assert_equal(myDisasm.infos.repr, 'vcvttss2usi esi, dword ptr [r8]')

        # EVEX.LIG.F2.0F.W1 78 /r
        # vcvttSD2USI r64, xmm1/m64{er}

        myEVEX = EVEX('EVEX.LIG.F2.0F.W1')
        Buffer = '{}7820'.format(myEVEX.prefix()).decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(myDisasm.infos.Instruction.Opcode, 0x78)
        assert_equal(myDisasm.infos.Reserved_.EVEX.W, 1)
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'vcvttsd2usi ')
        assert_equal(myDisasm.infos.repr, 'vcvttsd2usi esi, qword ptr [r8]')

        myEVEX = EVEX('EVEX.LIG.F2.0F.W1')
        Buffer = '{}78c0'.format(myEVEX.prefix()).decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(myDisasm.infos.Instruction.Opcode, 0x78)
        assert_equal(myDisasm.infos.Reserved_.EVEX.W, 1)
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'vcvttsd2usi ')
        assert_equal(myDisasm.infos.repr, 'vcvttsd2usi esp, xmm24')
