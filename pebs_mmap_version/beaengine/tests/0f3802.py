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
    """
    Packed Horizontal Add
    - phaddd Pq, Qq
    - vphaddd Vx, Hx, Wx
    """
    def test(self):
        # NP 0F 38 02 /r1
        # PHADDW mm1, mm2/m64

        Buffer = '0f38029011223344'.decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(hex(myDisasm.infos.Instruction.Opcode), '0xf3802')
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'phaddd ')
        assert_equal(myDisasm.infos.repr, 'phaddd mm2, qword ptr [rax+44332211h]')

        # 66 0F 38 02 /r
        # PHADDW xmm1, xmm2/m128

        Buffer = '660f38029011223344'.decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(hex(myDisasm.infos.Instruction.Opcode), '0xf3802')
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'phaddd ')
        assert_equal(myDisasm.infos.repr, 'phaddd xmm2, xmmword ptr [rax+44332211h]')

        # VEX.NDS.128.66.0F38.WIG 02 /r
        # VPHADDW xmm1, xmm2, xmm3/m128

        Buffer = 'c40201020e'.decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'vphaddd ')
        assert_equal(myDisasm.infos.repr, 'vphaddd xmm9, xmm15, xmmword ptr [r14]')

        # VEX.NDS.256.66.0F38.WIG 02 /r
        # VPHADDW ymm1, ymm2, ymm3/m256

        Buffer = 'c40205020e'.decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'vphaddd ')
        assert_equal(myDisasm.infos.repr, 'vphaddd ymm9, ymm15, ymmword ptr [r14]')
