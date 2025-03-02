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
    Variable Blend Packed
    """

    def test(self):

        # VEX.128.66.0F3A.W0 4B /r /is4
        # vblendvpd xmm1, xmm2, xmm3/m128, xmm4

        myVEX = VEX()
        myVEX.L = 0
        myVEX.W = 0
        myVEX.pp = 0b1
        myVEX.mmmm = 0b11
        myVEX.vvvv = 0b0
        myVEX.R = 1
        myVEX.B = 1

        Buffer = 'c4{:02x}{:02x}4b2700'.format(myVEX.byte1(), myVEX.byte2()).decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(myDisasm.infos.repr, 'vblendvpd xmm4, xmm15, xmmword ptr [rdi], xmm0')

        # VEX.256.66.0F3A.W0 4B /r /is4
        # VPBLENDVPS ymm1, ymm2, ymm3/m256, ymm4

        myVEX.reset()
        myVEX.L = 1
        myVEX.pp = 0b1
        myVEX.mmmm = 0b11
        myVEX.vvvv = 0b0
        myVEX.R = 1
        myVEX.B = 1

        Buffer = 'c4{:02x}{:02x}4b0e50'.format(myVEX.byte1(), myVEX.byte2()).decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(myDisasm.infos.repr, 'vblendvpd ymm1, ymm15, ymmword ptr [rsi], ymm5')


        # if VEX.W = 1 #UD

        myVEX.reset()
        myVEX.W = 1
        myVEX.L = 1
        myVEX.pp = 0b1
        myVEX.mmmm = 0b11

        Buffer = 'c4{:02x}{:02x}4b0000'.format(myVEX.byte1(), myVEX.byte2()).decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'vblendvpd ')
        assert_equal(myDisasm.infos.Reserved_.ERROR_OPCODE, UD_)
