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


        # EVEX.128.66.0F3A.W0 1f /r ib
        # VPCMPd k1 {k2}, xmm2, xmm3/m128/m32bcst, imm8

        myEVEX = EVEX('EVEX.128.66.0F3A.W0')
        Buffer = '{}1f2010'.format(myEVEX.prefix()).decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(myDisasm.infos.Instruction.Opcode, 0x1f)
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'vpcmpeqd ')
        assert_equal(myDisasm.infos.repr, 'vpcmpeqd k?, xmm16, xmmword ptr [r8], 10h')

        myEVEX = EVEX('EVEX.128.66.0F3A.W0')
        Buffer = '{}1f2011'.format(myEVEX.prefix()).decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(myDisasm.infos.Instruction.Opcode, 0x1f)
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'vpcmpltd ')
        assert_equal(myDisasm.infos.repr, 'vpcmpltd k?, xmm16, xmmword ptr [r8], 11h')

        myEVEX = EVEX('EVEX.128.66.0F3A.W0')
        Buffer = '{}1f2012'.format(myEVEX.prefix()).decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(myDisasm.infos.Instruction.Opcode, 0x1f)
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'vpcmpled ')
        assert_equal(myDisasm.infos.repr, 'vpcmpled k?, xmm16, xmmword ptr [r8], 12h')

        myEVEX = EVEX('EVEX.128.66.0F3A.W0')
        Buffer = '{}1f2013'.format(myEVEX.prefix()).decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(myDisasm.infos.Instruction.Opcode, 0x1f)
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'vpcmpfalsed ')
        assert_equal(myDisasm.infos.repr, 'vpcmpfalsed k?, xmm16, xmmword ptr [r8], 13h')

        myEVEX = EVEX('EVEX.128.66.0F3A.W0')
        Buffer = '{}1f2014'.format(myEVEX.prefix()).decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(myDisasm.infos.Instruction.Opcode, 0x1f)
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'vpcmpneqd ')
        assert_equal(myDisasm.infos.repr, 'vpcmpneqd k?, xmm16, xmmword ptr [r8], 14h')

        myEVEX = EVEX('EVEX.128.66.0F3A.W0')
        Buffer = '{}1f2015'.format(myEVEX.prefix()).decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(myDisasm.infos.Instruction.Opcode, 0x1f)
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'vpcmpnltd ')
        assert_equal(myDisasm.infos.repr, 'vpcmpnltd k?, xmm16, xmmword ptr [r8], 15h')

        myEVEX = EVEX('EVEX.128.66.0F3A.W0')
        Buffer = '{}1f2016'.format(myEVEX.prefix()).decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(myDisasm.infos.Instruction.Opcode, 0x1f)
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'vpcmpnled ')
        assert_equal(myDisasm.infos.repr, 'vpcmpnled k?, xmm16, xmmword ptr [r8], 16h')

        myEVEX = EVEX('EVEX.128.66.0F3A.W0')
        Buffer = '{}1f2017'.format(myEVEX.prefix()).decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(myDisasm.infos.Instruction.Opcode, 0x1f)
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'vpcmptrued ')
        assert_equal(myDisasm.infos.repr, 'vpcmptrued k?, xmm16, xmmword ptr [r8], 17h')

        # EVEX.256.66.0F3A.W0 1f /r ib
        # VPCMPd k1 {k2}, ymm2, ymm3/m256/m32bcst, imm8

        myEVEX = EVEX('EVEX.256.66.0F3A.W0')
        Buffer = '{}1f2010'.format(myEVEX.prefix()).decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(myDisasm.infos.Instruction.Opcode, 0x1f)
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'vpcmpeqd ')
        assert_equal(myDisasm.infos.repr, 'vpcmpeqd k?, ymm16, ymmword ptr [r8], 10h')

        # EVEX.512.66.0F3A.W0 1f /r ib
        # VPCMPd k1 {k2}, zmm2, zmm3/m512/m32bcst, imm8

        myEVEX = EVEX('EVEX.512.66.0F3A.W0')
        Buffer = '{}1f2010'.format(myEVEX.prefix()).decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(myDisasm.infos.Instruction.Opcode, 0x1f)
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'vpcmpeqd ')
        assert_equal(myDisasm.infos.repr, 'vpcmpeqd k?, zmm16, zmmword ptr [r8], 10h')



        # EVEX.128.66.0F3A.W1 1f /r ib
        # VPCMPq k1 {k2}, xmm2, xmm3/m128/m64bcst, imm8

        myEVEX = EVEX('EVEX.128.66.0F3A.W1')
        Buffer = '{}1f2010'.format(myEVEX.prefix()).decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(myDisasm.infos.Instruction.Opcode, 0x1f)
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'vpcmpeqq ')
        assert_equal(myDisasm.infos.repr, 'vpcmpeqq k?, xmm16, xmmword ptr [r8], 10h')

        # EVEX.256.66.0F3A.W1 1f /r ib
        # VPCMPq k1 {k2}, ymm2, ymm3/m256/m64bcst, imm8

        myEVEX = EVEX('EVEX.256.66.0F3A.W1')
        Buffer = '{}1f2010'.format(myEVEX.prefix()).decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(myDisasm.infos.Instruction.Opcode, 0x1f)
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'vpcmpeqq ')
        assert_equal(myDisasm.infos.repr, 'vpcmpeqq k?, ymm16, ymmword ptr [r8], 10h')

        # EVEX.512.66.0F3A.W1 1f /r ib
        # VPCMPq k1 {k2}, zmm2, zmm3/m512/m64bcst, imm8

        myEVEX = EVEX('EVEX.512.66.0F3A.W1')
        Buffer = '{}1f2010'.format(myEVEX.prefix()).decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.read()
        assert_equal(myDisasm.infos.Instruction.Opcode, 0x1f)
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'vpcmpeqq ')
        assert_equal(myDisasm.infos.repr, 'vpcmpeqq k?, zmm16, zmmword ptr [r8], 10h')
