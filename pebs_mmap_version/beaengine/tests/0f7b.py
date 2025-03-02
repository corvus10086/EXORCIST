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

        # EVEX.128.66.0F.W0 7B /r
        # VCVTPS2QQ xmm1 {k1}{z}, xmm2/m64/m32bcst

        myEVEX = EVEX('EVEX.128.66.0F.W0')
        Buffer = '{}7b20'.format(myEVEX.prefix()).decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(myDisasm.infos.Instruction.Opcode, 0x7b)
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'vcvtps2qq ')
        assert_equal(myDisasm.infos.repr, 'vcvtps2qq xmm28, qword ptr [r8]')

        # EVEX.256.66.0F.W0 7B /r
        # VCVTPS2QQ ymm1 {k1}{z}, xmm2/m128/m32bcst

        myEVEX = EVEX('EVEX.256.66.0F.W0')
        Buffer = '{}7b20'.format(myEVEX.prefix()).decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(myDisasm.infos.Instruction.Opcode, 0x7b)
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'vcvtps2qq ')
        assert_equal(myDisasm.infos.repr, 'vcvtps2qq ymm28, xmmword ptr [r8]')

        # EVEX.512.66.0F.W0 7B /r
        # VCVTPS2QQ zmm1 {k1}{z}, ymm2/m256/m32bcst{er}

        myEVEX = EVEX('EVEX.512.66.0F.W0')
        Buffer = '{}7b20'.format(myEVEX.prefix()).decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(myDisasm.infos.Instruction.Opcode, 0x7b)
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'vcvtps2qq ')
        assert_equal(myDisasm.infos.repr, 'vcvtps2qq zmm28, ymmword ptr [r8]')

        # EVEX.NDS.LIG.F2.0F.W0 7B /r
        # VCVTUSI2SD xmm1, xmm2, r/m32

        myEVEX = EVEX('EVEX.NDS.LIG.F2.0F.W0')
        Buffer = '{}7b20'.format(myEVEX.prefix()).decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(myDisasm.infos.Instruction.Opcode, 0x7b)
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'vcvtusi2sd ')
        assert_equal(myDisasm.infos.repr, 'vcvtusi2sd xmm28, xmm31, dword ptr [r8]')

        # EVEX.NDS.LIG.F2.0F.W1 7B /r
        # VCVTUSI2SD xmm1, xmm2, r/m64{er}

        myEVEX = EVEX('EVEX.NDS.LIG.F2.0F.W1')
        Buffer = '{}7b20'.format(myEVEX.prefix()).decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(myDisasm.infos.Instruction.Opcode, 0x7b)
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'vcvtusi2sd ')
        assert_equal(myDisasm.infos.repr, 'vcvtusi2sd xmm28, xmm31, qword ptr [r8]')

        # EVEX.NDS.LIG.F3.0F.W0 7B /r
        # VCVTUSI2SS xmm1, xmm2, r/m32{er}

        myEVEX = EVEX('EVEX.NDS.LIG.F3.0F.W0')
        Buffer = '{}7b20'.format(myEVEX.prefix()).decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(myDisasm.infos.Instruction.Opcode, 0x7b)
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'vcvtusi2ss ')
        assert_equal(myDisasm.infos.repr, 'vcvtusi2ss xmm28, xmm31, dword ptr [r8]')

        # EVEX.NDS.LIG.F3.0F.W1 7B /r
        # VCVTUSI2SS xmm1, xmm2, r/m64{er}

        myEVEX = EVEX('EVEX.NDS.LIG.F3.0F.W1')
        Buffer = '{}7b20'.format(myEVEX.prefix()).decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(myDisasm.infos.Instruction.Opcode, 0x7b)
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'vcvtusi2ss ')
        assert_equal(myDisasm.infos.repr, 'vcvtusi2ss xmm28, xmm31, qword ptr [r8]')

        # EVEX.128.66.0F.W1 7B /r
        # VCVTPD2QQ xmm1 {k1}{z}, xmm2/m128/m64bcst

        myEVEX = EVEX('EVEX.128.66.0F.W1')
        Buffer = '{}7b20'.format(myEVEX.prefix()).decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(myDisasm.infos.Instruction.Opcode, 0x7b)
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'vcvtpd2qq ')
        assert_equal(myDisasm.infos.repr, 'vcvtpd2qq xmm28, xmmword ptr [r8]')

        # EVEX.256.66.0F.W1 7B /r
        # VCVTPD2QQ ymm1 {k1}{z}, ymm2/m256/m64bcst

        myEVEX = EVEX('EVEX.256.66.0F.W1')
        Buffer = '{}7b20'.format(myEVEX.prefix()).decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(myDisasm.infos.Instruction.Opcode, 0x7b)
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'vcvtpd2qq ')
        assert_equal(myDisasm.infos.repr, 'vcvtpd2qq ymm28, ymmword ptr [r8]')

        # EVEX.512.66.0F.W1 7B /r
        # VCVTPD2QQ zmm1 {k1}{z}, zmm2/m512/m64bcst{er}

        myEVEX = EVEX('EVEX.512.66.0F.W1')
        Buffer = '{}7b20'.format(myEVEX.prefix()).decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(myDisasm.infos.Instruction.Opcode, 0x7b)
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'vcvtpd2qq ')
        assert_equal(myDisasm.infos.repr, 'vcvtpd2qq zmm28, zmmword ptr [r8]')
