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

        # EVEX.128.66.0F.W0 7A /r
        # VCVTTPS2QQ xmm1 {k1}{z}, xmm2/m64/m32bcst

        myEVEX = EVEX('EVEX.128.66.0F.W0')
        Buffer = '{}7a20'.format(myEVEX.prefix()).decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(myDisasm.infos.Instruction.Opcode, 0x7a)
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'vcvttps2qq ')
        assert_equal(myDisasm.infos.repr, 'vcvttps2qq xmm28, qword ptr [r8]')

        # EVEX.256.66.0F.W0 7A /r
        # VCVTTPS2QQ ymm1 {k1}{z}, xmm2/m128/m32bcst

        myEVEX = EVEX('EVEX.256.66.0F.W0')
        Buffer = '{}7a20'.format(myEVEX.prefix()).decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(myDisasm.infos.Instruction.Opcode, 0x7a)
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'vcvttps2qq ')
        assert_equal(myDisasm.infos.repr, 'vcvttps2qq ymm28, xmmword ptr [r8]')

        # EVEX.512.66.0F.W0 7A /r
        # VCVTTPS2QQ zmm1 {k1}{z}, ymm2/m256/m32bcst{sae}

        myEVEX = EVEX('EVEX.512.66.0F.W0')
        Buffer = '{}7a20'.format(myEVEX.prefix()).decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(myDisasm.infos.Instruction.Opcode, 0x7a)
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'vcvttps2qq ')
        assert_equal(myDisasm.infos.repr, 'vcvttps2qq zmm28, ymmword ptr [r8]')

        # EVEX.128.66.0F.W1 7A /r
        # VCVTTPD2QQ xmm1 {k1}{z}, xmm2/m128/m64bcst

        myEVEX = EVEX('EVEX.128.66.0F.W1')
        Buffer = '{}7a20'.format(myEVEX.prefix()).decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(myDisasm.infos.Instruction.Opcode, 0x7a)
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'vcvttpd2qq ')
        assert_equal(myDisasm.infos.repr, 'vcvttpd2qq xmm28, xmmword ptr [r8]')

        # EVEX.256.66.0F.W1 7A /r
        # VCVTTPD2QQ ymm1 {k1}{z}, ymm2/m256/m64bcst

        myEVEX = EVEX('EVEX.256.66.0F.W1')
        Buffer = '{}7a20'.format(myEVEX.prefix()).decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(myDisasm.infos.Instruction.Opcode, 0x7a)
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'vcvttpd2qq ')
        assert_equal(myDisasm.infos.repr, 'vcvttpd2qq ymm28, ymmword ptr [r8]')

        # EVEX.512.66.0F.W1 7A /r
        # VCVTTPD2QQ zmm1 {k1}{z}, zmm2/m512/m64bcst{sae}

        myEVEX = EVEX('EVEX.512.66.0F.W1')
        Buffer = '{}7a20'.format(myEVEX.prefix()).decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(myDisasm.infos.Instruction.Opcode, 0x7a)
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'vcvttpd2qq ')
        assert_equal(myDisasm.infos.repr, 'vcvttpd2qq zmm28, zmmword ptr [r8]')

        # EVEX.128.F3.0F.W0 7A /r
        # VCVTUDQ2PD xmm1 {k1}{z}, xmm2/m64/m32bcst

        myEVEX = EVEX('EVEX.128.F3.0F.W0')
        Buffer = '{}7a20'.format(myEVEX.prefix()).decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(myDisasm.infos.Instruction.Opcode, 0x7a)
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'vcvtudq2pd ')
        assert_equal(myDisasm.infos.repr, 'vcvtudq2pd xmm28, qword ptr [r8]')

        # EVEX.256.F3.0F.W0 7A /r
        # VCVTUDQ2PD ymm1 {k1}{z}, xmm2/m128/m32bcst

        myEVEX = EVEX('EVEX.256.F3.0F.W0')
        Buffer = '{}7a20'.format(myEVEX.prefix()).decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(myDisasm.infos.Instruction.Opcode, 0x7a)
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'vcvtudq2pd ')
        assert_equal(myDisasm.infos.repr, 'vcvtudq2pd ymm28, xmmword ptr [r8]')

        # EVEX.512.F3.0F.W0 7A /r
        # VCVTUDQ2PD zmm1 {k1}{z}, ymm2/m256/m32bcst

        myEVEX = EVEX('EVEX.512.F3.0F.W0')
        Buffer = '{}7a20'.format(myEVEX.prefix()).decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(myDisasm.infos.Instruction.Opcode, 0x7a)
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'vcvtudq2pd ')
        assert_equal(myDisasm.infos.repr, 'vcvtudq2pd zmm28, ymmword ptr [r8]')

        # EVEX.128.F3.0F.W1 7A /r
        # VCVTUQQ2PD xmm1 {k1}{z}, xmm2/m128/m64bcst

        myEVEX = EVEX('EVEX.128.F3.0F.W1')
        Buffer = '{}7a20'.format(myEVEX.prefix()).decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(myDisasm.infos.Instruction.Opcode, 0x7a)
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'vcvtuqq2pd ')
        assert_equal(myDisasm.infos.repr, 'vcvtuqq2pd xmm28, xmmword ptr [r8]')

        # EVEX.256.F3.0F.W1 7A /r
        # VCVTUQQ2PD ymm1 {k1}{z}, ymm2/m256/m64bcst

        myEVEX = EVEX('EVEX.256.F3.0F.W1')
        Buffer = '{}7a20'.format(myEVEX.prefix()).decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(myDisasm.infos.Instruction.Opcode, 0x7a)
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'vcvtuqq2pd ')
        assert_equal(myDisasm.infos.repr, 'vcvtuqq2pd ymm28, ymmword ptr [r8]')

        # EVEX.512.F3.0F.W1 7A /r
        # VCVTUQQ2PD zmm1 {k1}{z}, zmm2/m512/m64bcst{er}

        myEVEX = EVEX('EVEX.512.F3.0F.W1')
        Buffer = '{}7a20'.format(myEVEX.prefix()).decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(myDisasm.infos.Instruction.Opcode, 0x7a)
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'vcvtuqq2pd ')
        assert_equal(myDisasm.infos.repr, 'vcvtuqq2pd zmm28, zmmword ptr [r8]')

        # EVEX.128.F2.0F.W0 7A /r
        # VCVTUDQ2PS xmm1 {k1}{z}, xmm2/m128/m32bcst

        myEVEX = EVEX('EVEX.128.F2.0F.W0')
        Buffer = '{}7a20'.format(myEVEX.prefix()).decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(myDisasm.infos.Instruction.Opcode, 0x7a)
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'vcvtudq2ps ')
        assert_equal(myDisasm.infos.repr, 'vcvtudq2ps xmm28, xmmword ptr [r8]')

        # EVEX.256.F2.0F.W0 7A /r
        # VCVTUDQ2PS ymm1 {k1}{z}, ymm2/m256/m32bcst

        myEVEX = EVEX('EVEX.256.F2.0F.W0')
        Buffer = '{}7a20'.format(myEVEX.prefix()).decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(myDisasm.infos.Instruction.Opcode, 0x7a)
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'vcvtudq2ps ')
        assert_equal(myDisasm.infos.repr, 'vcvtudq2ps ymm28, ymmword ptr [r8]')

        # EVEX.512.F2.0F.W0 7A /r
        # VCVTUDQ2PS zmm1 {k1}{z}, zmm2/m512/m32bcst{er}

        myEVEX = EVEX('EVEX.512.F2.0F.W0')
        Buffer = '{}7a20'.format(myEVEX.prefix()).decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(myDisasm.infos.Instruction.Opcode, 0x7a)
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'vcvtudq2ps ')
        assert_equal(myDisasm.infos.repr, 'vcvtudq2ps zmm28, zmmword ptr [r8]')

        # EVEX.128.F2.0F.W1 7A /r
        # VCVTUQQ2PS xmm1 {k1}{z}, xmm2/m128/m64bcst

        myEVEX = EVEX('EVEX.128.F2.0F.W1')
        Buffer = '{}7a20'.format(myEVEX.prefix()).decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(myDisasm.infos.Instruction.Opcode, 0x7a)
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'vcvtuqq2ps ')
        assert_equal(myDisasm.infos.repr, 'vcvtuqq2ps xmm28, xmmword ptr [r8]')

        # EVEX.256.F2.0F.W1 7A /r
        # VCVTUQQ2PS xmm1 {k1}{z}, ymm2/m256/m64bcst

        myEVEX = EVEX('EVEX.256.F2.0F.W1')
        Buffer = '{}7a20'.format(myEVEX.prefix()).decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(myDisasm.infos.Instruction.Opcode, 0x7a)
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'vcvtuqq2ps ')
        assert_equal(myDisasm.infos.repr, 'vcvtuqq2ps xmm28, ymmword ptr [r8]')

        # EVEX.512.F2.0F.W1 7A /r
        # VCVTUQQ2PS ymm1 {k1}{z}, zmm2/m512/m64bcst{er}

        myEVEX = EVEX('EVEX.512.F2.0F.W1')
        Buffer = '{}7a20'.format(myEVEX.prefix()).decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(myDisasm.infos.Instruction.Opcode, 0x7a)
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'vcvtuqq2ps ')
        assert_equal(myDisasm.infos.repr, 'vcvtuqq2ps ymm28, zmmword ptr [r8]')
