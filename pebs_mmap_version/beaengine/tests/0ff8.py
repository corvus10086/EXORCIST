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
        # 66 0F f8 /r
        # psubb mm1, mm2/m64
        Buffer = '660ff89011223344'.decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(hex(myDisasm.infos.Instruction.Opcode), '0xff8')
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'psubb ')
        assert_equal(myDisasm.infos.repr, 'psubb xmm2, xmmword ptr [rax+44332211h]')

        # VEX.NDS.128.66.0F.WIG f8 /r
        # vpsubb xmm1, xmm2, xmm3/m128
        Buffer = 'c40101f80e'.decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'vpsubb ')
        assert_equal(myDisasm.infos.repr, 'vpsubb xmm9, xmm15, xmmword ptr [r14]')

        # VEX.NDS.256.66.0F.WIG f8 /r
        # vpsubb ymm1, ymm2, ymm3/m256
        Buffer = 'c40105f80e'.decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'vpsubb ')
        assert_equal(myDisasm.infos.repr, 'vpsubb ymm9, ymm15, ymmword ptr [r14]')

        # EVEX.NDS.128.66.0F.WIG f8 /r
        # vpsubb xmm1 {k1}{z}, xmm2, xmm3/m128
        Buffer = '62010506f80e'.decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(myDisasm.infos.Reserved_.EVEX.P0, 0x1)
        assert_equal(myDisasm.infos.Reserved_.EVEX.P1, 0x5)
        assert_equal(myDisasm.infos.Reserved_.EVEX.P2, 0x6)
        assert_equal(myDisasm.infos.Reserved_.EVEX.pp, 0x1)
        assert_equal(myDisasm.infos.Reserved_.EVEX.mm, 0x1)
        assert_equal(hex(myDisasm.infos.Instruction.Opcode), '0xf8')
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'vpsubb ')
        assert_equal(myDisasm.infos.repr, 'vpsubb xmm25, xmm31, xmmword ptr [r14]')

        # EVEX.NDS.256.66.0F.WIG f8 /r
        # vpsubb ymm1 {k1}{z}, ymm2, ymm3/m256
        Buffer = '62010520f80e'.decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(myDisasm.infos.Reserved_.EVEX.P0, 0x1)
        assert_equal(myDisasm.infos.Reserved_.EVEX.P1, 0x5)
        assert_equal(myDisasm.infos.Reserved_.EVEX.P2, 0x20)
        assert_equal(myDisasm.infos.Reserved_.EVEX.pp, 0x1)
        assert_equal(myDisasm.infos.Reserved_.EVEX.mm, 0x1)
        assert_equal(hex(myDisasm.infos.Instruction.Opcode), '0xf8')
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'vpsubb ')
        assert_equal(myDisasm.infos.repr, 'vpsubb ymm25, ymm31, ymmword ptr [r14]')

        # EVEX.NDS.512.66.0F.WIG f8 /r
        # vpsubb zmm1 {k1}{z}, zmm2, zmm3/m512
        Buffer = '62010540f80e'.decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(myDisasm.infos.Reserved_.EVEX.P0, 0x1)
        assert_equal(myDisasm.infos.Reserved_.EVEX.P1, 0x5)
        assert_equal(myDisasm.infos.Reserved_.EVEX.P2, 0x40)
        assert_equal(myDisasm.infos.Reserved_.EVEX.pp, 0x1)
        assert_equal(myDisasm.infos.Reserved_.EVEX.mm, 0x1)
        assert_equal(hex(myDisasm.infos.Instruction.Opcode), '0xf8')
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'vpsubb ')
        assert_equal(myDisasm.infos.repr, 'vpsubb zmm25, zmm31, zmmword ptr [r14]')
