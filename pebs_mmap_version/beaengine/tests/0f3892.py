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


        # EVEX.128.66.0F38.W0 92 /vsib
        # VgatherdPS xmm1 {k1}, vm64x

        myEVEX = EVEX('EVEX.128.66.0F38.W0')
        Buffer = '{}92443322'.format(myEVEX.prefix()).decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'vgatherdps ')
        #assert_equal(myDisasm.infos.Reserved_.EVEX.X, 1)
        assert_equal(myDisasm.infos.repr, 'vgatherdps xmm24, dword ptr [r11+xmm30+22h]')

        # EVEX.256.66.0F38.W0 92 /vsib
        # VgatherdPS xmm1 {k1}, vm64y

        myEVEX = EVEX('EVEX.256.66.0F38.W0')
        Buffer = '{}92443322'.format(myEVEX.prefix()).decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'vgatherdps ')
        assert_equal(myDisasm.infos.repr, 'vgatherdps xmm24, dword ptr [r11+ymm30+22h]')

        # EVEX.512.66.0F38.W0 92 /vsib
        # VgatherdPS ymm1 {k1}, vm64z

        myEVEX = EVEX('EVEX.512.66.0F38.W0')
        Buffer = '{}92443322'.format(myEVEX.prefix()).decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'vgatherdps ')
        assert_equal(myDisasm.infos.repr, 'vgatherdps ymm24, dword ptr [r11+zmm30+0088h]')

        # EVEX.128.66.0F38.W1 92 /vsib
        # VgatherdPD xmm1 {k1}, vm64x

        myEVEX = EVEX('EVEX.128.66.0F38.W1')
        Buffer = '{}92443322'.format(myEVEX.prefix()).decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'vgatherdpd ')
        assert_equal(myDisasm.infos.repr, 'vgatherdpd xmm24, dword ptr [r11+xmm30+22h]')

        # EVEX.256.66.0F38.W1 92 /vsib
        # VgatherdPD ymm1 {k1}, vm64y

        myEVEX = EVEX('EVEX.256.66.0F38.W1')
        Buffer = '{}92443322'.format(myEVEX.prefix()).decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'vgatherdpd ')
        assert_equal(myDisasm.infos.repr, 'vgatherdpd ymm24, dword ptr [r11+ymm30+22h]')

        # EVEX.512.66.0F38.W1 92 /vsib
        # VgatherdPD zmm1 {k1}, vm64z

        myEVEX = EVEX('EVEX.512.66.0F38.W1')
        Buffer = '{}92443322'.format(myEVEX.prefix()).decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'vgatherdpd ')
        assert_equal(myDisasm.infos.repr, 'vgatherdpd zmm24, dword ptr [r11+zmm30+0110h]')

        # VEX.DDS.128.66.0F38.W1 92 /r
        # VgatherdPD xmm1, vm64x, xmm2

        myVEX = VEX('VEX.DDS.128.66.0F38.W1')
        Buffer = '{}92443322'.format(myVEX.c4()).decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'vgatherdpd ')
        assert_equal(myDisasm.infos.repr, 'vgatherdpd xmm8, dword ptr [r11+xmm14+22h], xmm15')

        # VEX.DDS.256.66.0F38.W1 92 /r
        # VgatherdPD ymm1, vm64y, ymm2

        myVEX = VEX('VEX.DDS.256.66.0F38.W1')
        Buffer = '{}92443322'.format(myVEX.c4()).decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'vgatherdpd ')
        assert_equal(myDisasm.infos.repr, 'vgatherdpd ymm8, dword ptr [r11+ymm14+22h], ymm15')

        # VEX.DDS.128.66.0F38.W0 92 /r
        # VgatherdPS xmm1, vm64x, xmm2

        myVEX = VEX('VEX.DDS.128.66.0F38.W0')
        Buffer = '{}92443322'.format(myVEX.c4()).decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'vgatherdps ')
        assert_equal(myDisasm.infos.repr, 'vgatherdps xmm8, dword ptr [r11+xmm14+22h], xmm15')

        # VEX.DDS.256.66.0F38.W0 92 /r
        # VgatherdPS xmm1, vm64y, xmm2

        myVEX = VEX('VEX.DDS.256.66.0F38.W0')
        Buffer = '{}92443322'.format(myVEX.c4()).decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'vgatherdps ')
        assert_equal(myDisasm.infos.repr, 'vgatherdps xmm8, dword ptr [r11+ymm14+22h], xmm15')
