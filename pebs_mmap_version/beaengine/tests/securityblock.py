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
# 

from headers.BeaEnginePython import *
from nose.tools import *

class TestSuite:

    def disassemble(self, buffer):
        myDisasm = Disasm(buffer)
        myDisasm.infos.SecurityBlock = len(buffer) - 1
        if myDisasm.infos.SecurityBlock != 0:
            myDisasm.read()
            if myDisasm.length != UNKNOWN_OPCODE:
                assert_equal(myDisasm.infos.Error, OUT_OF_BLOCK)

    def disasmVEX0F(self, i):

        myVEX = VEX('VEX.NDS.128.0F.W0')
        myVEX.vvvv = 0b1111
        myVEX.R = 1
        Buffer = '{}{:02x}443322'.format(myVEX.c4(), i).decode('hex')
        self.disassemble(Buffer)

        myVEX = VEX('VEX.L1.66.0F.W0')
        myVEX.vvvv = 0b1101
        myVEX.R = 1
        Buffer = '{}{:02x}cb'.format(myVEX.c4(), i).decode('hex')
        self.disassemble(Buffer)

        myVEX = VEX('VEX.NDS.128.0F.W0')
        myVEX.R = 1
        myVEX.vvvv = 0b1111
        Buffer = '{}{:02x}443322'.format(myVEX.c4(), i).decode('hex')
        self.disassemble(Buffer)

        myVEX = VEX('VEX.128.66.0F.W0')
        myVEX.R = 1
        myVEX.vvvv = 0b1111
        Buffer = '{}{:02x}443322'.format(myVEX.c4(), i).decode('hex')
        self.disassemble(Buffer)

        myVEX = VEX('VEX.NDS.128.66.0F.W0')
        myVEX.R = 1
        myVEX.vvvv = 0b1111
        Buffer = '{}{:02x}443322'.format(myVEX.c4(), i).decode('hex')
        self.disassemble(Buffer)

        myVEX = VEX('VEX.NDS.128.F2.0F.W0')
        myVEX.R = 1
        myVEX.vvvv = 0b1111
        Buffer = '{}{:02x}443322'.format(myVEX.c4(), i).decode('hex')
        self.disassemble(Buffer)

        myVEX = VEX('VEX.NDS.128.F3.0F.W0')
        myVEX.R = 1
        myVEX.vvvv = 0b1111
        Buffer = '{}{:02x}443322'.format(myVEX.c4(), i).decode('hex')
        self.disassemble(Buffer)

        myVEX = VEX('VEX.NDS.128.66.0F.W1')
        myVEX.R = 1
        myVEX.vvvv = 0b1111
        Buffer = '{}{:02x}443322'.format(myVEX.c4(), i).decode('hex')
        self.disassemble(Buffer)

        myVEX = VEX('VEX.NDS.128.F2.0F.W1')
        myVEX.R = 1
        myVEX.vvvv = 0b1111
        Buffer = '{}{:02x}443322'.format(myVEX.c4(), i).decode('hex')
        self.disassemble(Buffer)

        myVEX = VEX('VEX.NDS.128.F3.0F.W1')
        myVEX.R = 1
        myVEX.vvvv = 0b1111
        Buffer = '{}{:02x}443322'.format(myVEX.c4(), i).decode('hex')
        self.disassemble(Buffer)

        myVEX = VEX('VEX.NDS.256.0F.W0')
        myVEX.R = 1
        myVEX.vvvv = 0b1111
        Buffer = '{}{:02x}443322'.format(myVEX.c4(), i).decode('hex')
        self.disassemble(Buffer)

        myVEX = VEX('VEX.NDS.256.66.0F.W0')
        myVEX.R = 1
        myVEX.vvvv = 0b1111
        Buffer = '{}{:02x}443322'.format(myVEX.c4(), i).decode('hex')
        self.disassemble(Buffer)

        myVEX = VEX('VEX.NDS.256.F2.0F.W0')
        myVEX.R = 1
        myVEX.vvvv = 0b1111
        Buffer = '{}{:02x}443322'.format(myVEX.c4(), i).decode('hex')
        self.disassemble(Buffer)

        myVEX = VEX('VEX.NDS.256.F3.0F.W0')
        myVEX.R = 1
        myVEX.vvvv = 0b1111
        Buffer = '{}{:02x}443322'.format(myVEX.c4(), i).decode('hex')
        self.disassemble(Buffer)

        myVEX = VEX('VEX.NDS.256.66.0F.W1')
        myVEX.R = 1
        myVEX.vvvv = 0b1111
        Buffer = '{}{:02x}443322'.format(myVEX.c4(), i).decode('hex')
        self.disassemble(Buffer)

        myVEX = VEX('VEX.NDS.256.F2.0F.W1')
        myVEX.R = 1
        myVEX.vvvv = 0b1111
        Buffer = '{}{:02x}443322'.format(myVEX.c4(), i).decode('hex')
        self.disassemble(Buffer)

        myVEX = VEX('VEX.NDS.256.F3.0F.W1')
        myVEX.R = 1
        myVEX.vvvv = 0b1111
        Buffer = '{}{:02x}443322'.format(myVEX.c4(), i).decode('hex')
        self.disassemble(Buffer)

        myVEX = VEX('VEX.NDS.128.0F.W0')
        myVEX.R = 1
        myVEX.vvvv = 0b1111
        Buffer = '{}{:02x}443322'.format(myVEX.c5(), i).decode('hex')
        self.disassemble(Buffer)

        myVEX = VEX('VEX.NDS.128.66.0F.W0')
        myVEX.R = 1
        myVEX.vvvv = 0b1111
        Buffer = '{}{:02x}443322'.format(myVEX.c5(), i).decode('hex')
        self.disassemble(Buffer)

        myVEX = VEX('VEX.NDS.128.F2.0F.W0')
        myVEX.R = 1
        myVEX.vvvv = 0b1111
        Buffer = '{}{:02x}443322'.format(myVEX.c5(), i).decode('hex')
        self.disassemble(Buffer)

        myVEX = VEX('VEX.NDS.128.F3.0F.W0')
        myVEX.R = 1
        myVEX.vvvv = 0b1111
        Buffer = '{}{:02x}443322'.format(myVEX.c5(), i).decode('hex')
        self.disassemble(Buffer)

    def disasmVEX0FNoModrm(self, i):

        myVEX = VEX('VEX.NDS.128.0F.W0')
        myVEX.vvvv = 0b1111
        myVEX.R = 1
        Buffer = '{}{:02x}'.format(myVEX.c4(), i).decode('hex')
        self.disassemble(Buffer)

        myVEX = VEX('VEX.L1.66.0F.W0')
        myVEX.vvvv = 0b1101
        myVEX.R = 1
        Buffer = '{}{:02x}'.format(myVEX.c4(), i).decode('hex')
        self.disassemble(Buffer)

        myVEX = VEX('VEX.NDS.128.0F.W0')
        myVEX.R = 1
        myVEX.vvvv = 0b1111
        Buffer = '{}{:02x}'.format(myVEX.c4(), i).decode('hex')
        self.disassemble(Buffer)

        myVEX = VEX('VEX.128.66.0F.W0')
        myVEX.R = 1
        myVEX.vvvv = 0b1111
        Buffer = '{}{:02x}443322'.format(myVEX.c4(), i).decode('hex')
        self.disassemble(Buffer)

        myVEX = VEX('VEX.NDS.128.66.0F.W0')
        myVEX.R = 1
        myVEX.vvvv = 0b1111
        Buffer = '{}{:02x}'.format(myVEX.c4(), i).decode('hex')
        self.disassemble(Buffer)

        myVEX = VEX('VEX.NDS.128.F2.0F.W0')
        myVEX.R = 1
        myVEX.vvvv = 0b1111
        Buffer = '{}{:02x}'.format(myVEX.c4(), i).decode('hex')
        self.disassemble(Buffer)

        myVEX = VEX('VEX.NDS.128.F3.0F.W0')
        myVEX.R = 1
        myVEX.vvvv = 0b1111
        Buffer = '{}{:02x}'.format(myVEX.c4(), i).decode('hex')
        self.disassemble(Buffer)

        myVEX = VEX('VEX.NDS.128.66.0F.W1')
        myVEX.R = 1
        myVEX.vvvv = 0b1111
        Buffer = '{}{:02x}'.format(myVEX.c4(), i).decode('hex')
        self.disassemble(Buffer)

        myVEX = VEX('VEX.NDS.128.F2.0F.W1')
        myVEX.R = 1
        myVEX.vvvv = 0b1111
        Buffer = '{}{:02x}'.format(myVEX.c4(), i).decode('hex')
        self.disassemble(Buffer)

        myVEX = VEX('VEX.NDS.128.F3.0F.W1')
        myVEX.R = 1
        myVEX.vvvv = 0b1111
        Buffer = '{}{:02x}'.format(myVEX.c4(), i).decode('hex')
        self.disassemble(Buffer)

        myVEX = VEX('VEX.NDS.256.0F.W0')
        myVEX.R = 1
        myVEX.vvvv = 0b1111
        Buffer = '{}{:02x}'.format(myVEX.c4(), i).decode('hex')
        self.disassemble(Buffer)

        myVEX = VEX('VEX.NDS.256.66.0F.W0')
        myVEX.R = 1
        myVEX.vvvv = 0b1111
        Buffer = '{}{:02x}'.format(myVEX.c4(), i).decode('hex')
        self.disassemble(Buffer)

        myVEX = VEX('VEX.NDS.256.F2.0F.W0')
        myVEX.R = 1
        myVEX.vvvv = 0b1111
        Buffer = '{}{:02x}'.format(myVEX.c4(), i).decode('hex')
        self.disassemble(Buffer)

        myVEX = VEX('VEX.NDS.256.F3.0F.W0')
        myVEX.R = 1
        myVEX.vvvv = 0b1111
        Buffer = '{}{:02x}'.format(myVEX.c4(), i).decode('hex')
        self.disassemble(Buffer)

        myVEX = VEX('VEX.NDS.256.66.0F.W1')
        myVEX.R = 1
        myVEX.vvvv = 0b1111
        Buffer = '{}{:02x}'.format(myVEX.c4(), i).decode('hex')
        self.disassemble(Buffer)

        myVEX = VEX('VEX.NDS.256.F2.0F.W1')
        myVEX.R = 1
        myVEX.vvvv = 0b1111
        Buffer = '{}{:02x}'.format(myVEX.c4(), i).decode('hex')
        self.disassemble(Buffer)

        myVEX = VEX('VEX.NDS.256.F3.0F.W1')
        myVEX.R = 1
        myVEX.vvvv = 0b1111
        Buffer = '{}{:02x}'.format(myVEX.c4(), i).decode('hex')
        self.disassemble(Buffer)

        myVEX = VEX('VEX.NDS.128.0F.W0')
        myVEX.R = 1
        myVEX.vvvv = 0b1111
        Buffer = '{}{:02x}'.format(myVEX.c5(), i).decode('hex')
        self.disassemble(Buffer)

        myVEX = VEX('VEX.NDS.128.66.0F.W0')
        myVEX.R = 1
        myVEX.vvvv = 0b1111
        Buffer = '{}{:02x}'.format(myVEX.c5(), i).decode('hex')
        self.disassemble(Buffer)

        myVEX = VEX('VEX.NDS.128.F2.0F.W0')
        myVEX.R = 1
        myVEX.vvvv = 0b1111
        Buffer = '{}{:02x}'.format(myVEX.c5(), i).decode('hex')
        self.disassemble(Buffer)

        myVEX = VEX('VEX.NDS.128.F3.0F.W0')
        myVEX.R = 1
        myVEX.vvvv = 0b1111
        Buffer = '{}{:02x}'.format(myVEX.c5(), i).decode('hex')
        self.disassemble(Buffer)

    def disasmNoModrm(self, i):
        self.disassemble('{:02x}'.format(i).decode('hex'))
        self.disassemble('66{:02x}'.format(i).decode('hex'))
        self.disassemble('f2{:02x}'.format(i).decode('hex'))
        self.disassemble('f3{:02x}'.format(i).decode('hex'))
        self.disassemble('f0{:02x}'.format(i).decode('hex'))
        myREX = REX()
        myREX.W = 1
        self.disassemble('{:02x}{:02x}'.format(myREX.byte(), i).decode('hex'))
        myREX = REX()
        myREX.R = 1
        self.disassemble('{:02x}{:02x}'.format(myREX.byte(), i).decode('hex'))

    def disasm0FNoModrm(self, i):
        self.disassemble('0f{:02x}'.format(i).decode('hex'))
        self.disassemble('660f{:02x}'.format(i).decode('hex'))
        self.disassemble('f20f{:02x}'.format(i).decode('hex'))
        self.disassemble('f30f{:02x}'.format(i).decode('hex'))
        self.disassemble('f00f{:02x}'.format(i).decode('hex'))
        myREX = REX()
        myREX.W = 1
        self.disassemble('{:02x}0f{:02x}'.format(myREX.byte(), i).decode('hex'))
        myREX = REX()
        myREX.R = 1
        self.disassemble('{:02x}0f{:02x}'.format(myREX.byte(), i).decode('hex'))

    def disasmNoImm(self, i):
        self.disassemble('{:02x}4011'.format(i).decode('hex'))
        self.disassemble('66{:02x}4011'.format(i).decode('hex'))
        self.disassemble('f2{:02x}4011'.format(i).decode('hex'))
        self.disassemble('f3{:02x}4011'.format(i).decode('hex'))
        self.disassemble('f0{:02x}4011'.format(i).decode('hex'))
        myREX = REX()
        myREX.W = 1
        self.disassemble('{:02x}{:02x}89ce00000000'.format(myREX.byte(), i).decode('hex'))
        myREX = REX()
        myREX.R = 1
        self.disassemble('{:02x}{:02x}89ce00000000'.format(myREX.byte(), i).decode('hex'))

    def disasm0FNoImm(self, i):
        self.disassemble('0f{:02x}4011'.format(i).decode('hex'))
        self.disassemble('660f{:02x}4011'.format(i).decode('hex'))
        self.disassemble('f20f{:02x}4011'.format(i).decode('hex'))
        self.disassemble('f30f{:02x}4011'.format(i).decode('hex'))
        self.disassemble('f00f{:02x}4011'.format(i).decode('hex'))
        myREX = REX()
        myREX.W = 1
        self.disassemble('{:02x}0f{:02x}89ce00000000'.format(myREX.byte(), i).decode('hex'))
        myREX = REX()
        myREX.R = 1
        self.disassemble('{:02x}0f{:02x}89ce00000000'.format(myREX.byte(), i).decode('hex'))

    def disasmImm8(self, i):
        self.disassemble('{:02x}401122'.format(i).decode('hex'))
        self.disassemble('66{:02x}401122'.format(i).decode('hex'))
        self.disassemble('f2{:02x}401122'.format(i).decode('hex'))
        self.disassemble('f3{:02x}401122'.format(i).decode('hex'))
        self.disassemble('f0{:02x}401122'.format(i).decode('hex'))
        myREX = REX()
        myREX.W = 1
        self.disassemble('{:02x}{:02x}89ce000000'.format(myREX.byte(), i).decode('hex'))
        myREX = REX()
        myREX.R = 1
        self.disassemble('{:02x}{:02x}89ce000000'.format(myREX.byte(), i).decode('hex'))

    def disasmNoModrmImm8(self, i):
        self.disassemble('{:02x}11'.format(i).decode('hex'))
        self.disassemble('66{:02x}11'.format(i).decode('hex'))
        self.disassemble('f2{:02x}11'.format(i).decode('hex'))
        self.disassemble('f3{:02x}11'.format(i).decode('hex'))
        self.disassemble('f0{:02x}11'.format(i).decode('hex'))
        myREX = REX()
        myREX.W = 1
        self.disassemble('{:02x}{:02x}22'.format(myREX.byte(), i).decode('hex'))
        myREX = REX()
        myREX.R = 1
        self.disassemble('{:02x}{:02x}22'.format(myREX.byte(), i).decode('hex'))

    def disasmImm32(self, i):
        self.disassemble('{:02x}401100112233'.format(i).decode('hex'))
        self.disassemble('66{:02x}40110011'.format(i).decode('hex'))
        self.disassemble('f2{:02x}401100112233'.format(i).decode('hex'))
        self.disassemble('f3{:02x}401100112233'.format(i).decode('hex'))
        self.disassemble('f0{:02x}401100112233'.format(i).decode('hex'))
        myREX = REX()
        myREX.W = 1
        self.disassemble('{:02x}{:02x}89ce000000000011'.format(myREX.byte(), i).decode('hex'))
        myREX = REX()
        myREX.R = 1
        self.disassemble('{:02x}{:02x}89ce000000000011'.format(myREX.byte(), i).decode('hex'))

    def disasmNoModrmImm32(self, i):
        self.disassemble('{:02x}00112233'.format(i).decode('hex'))
        self.disassemble('f2{:02x}00112233'.format(i).decode('hex'))
        self.disassemble('66{:02x}0011'.format(i).decode('hex'))
        self.disassemble('f3{:02x}00112233'.format(i).decode('hex'))
        self.disassemble('f0{:02x}00112233'.format(i).decode('hex'))
        myREX = REX()
        myREX.W = 1
        self.disassemble('{:02x}{:02x}00112233'.format(myREX.byte(), i).decode('hex'))
        myREX = REX()
        myREX.R = 1
        self.disassemble('{:02x}{:02x}00112233'.format(myREX.byte(), i).decode('hex'))

    def test2(self):
        # 1 byte G1
        for i in range(0, 8):
            self.disassemble('80{:02x}11'.format(i*8).decode('hex'))
            self.disassemble('80{:02x}11'.format(i*8 + 0xc0).decode('hex'))

        # 1 byte G1
        for i in range(0, 8):
            self.disassemble('81{:02x}11223344'.format(i*8).decode('hex'))
            self.disassemble('81{:02x}11223344'.format(i*8 + 0xc0).decode('hex'))

        # 1 byte G1
        for i in range(0, 8):
            self.disassemble('82{:02x}11'.format(i*8).decode('hex'))
            self.disassemble('82{:02x}11'.format(i*8 + 0xc0).decode('hex'))

        # 1 byte G1
        for i in range(0, 8):
            self.disassemble('83{:02x}11'.format(i*8).decode('hex'))
            self.disassemble('83{:02x}11'.format(i*8 + 0xc0).decode('hex'))

        # 1 byte G2
        for i in range(0, 8):
            self.disassemble('c0{:02x}11'.format(i*8).decode('hex'))
            self.disassemble('c0{:02x}11'.format(i*8 + 0xc0).decode('hex'))

        # 1 byte G2
        for i in range(0, 8):
            self.disassemble('c1{:02x}11'.format(i*8).decode('hex'))
            self.disassemble('c1{:02x}11'.format(i*8 + 0xc0).decode('hex'))

        # 1 byte G2
        for i in range(0, 8):
            self.disassemble('d0{:02x}'.format(i*8).decode('hex'))
            self.disassemble('d0{:02x}'.format(i*8 + 0xc0).decode('hex'))

        # 1 byte G2
        for i in range(0, 8):
            self.disassemble('d1{:02x}'.format(i*8).decode('hex'))
            self.disassemble('d1{:02x}'.format(i*8 + 0xc0).decode('hex'))

        # 1 byte G2
        for i in range(0, 8):
            self.disassemble('d2{:02x}'.format(i*8).decode('hex'))
            self.disassemble('d2{:02x}'.format(i*8 + 0xc0).decode('hex'))

        # 1 byte G2
        for i in range(0, 8):
            self.disassemble('d3{:02x}'.format(i*8).decode('hex'))
            self.disassemble('d3{:02x}'.format(i*8 + 0xc0).decode('hex'))

        # 1 byte G3
        for i in range(0, 8):
            self.disassemble('f6{:02x}'.format(i*8).decode('hex'))
            self.disassemble('f6{:02x}'.format(i*8 + 0xc0).decode('hex'))

        # 1 byte G3
        for i in range(0, 8):
            self.disassemble('f7{:02x}'.format(i*8).decode('hex'))
            self.disassemble('f7{:02x}'.format(i*8 + 0xc0).decode('hex'))

        # 1 byte G4
        for i in range(0, 8):
            self.disassemble('fe{:02x}'.format(i*8).decode('hex'))
            self.disassemble('fe{:02x}'.format(i*8 + 0xc0).decode('hex'))

        # 1 byte G5
        for i in range(0, 8):
            self.disassemble('ff{:02x}'.format(i*8).decode('hex'))
            self.disassemble('ff{:02x}'.format(i*8 + 0xc0).decode('hex'))

        # 2 bytes G6
        for i in range(0, 8):
            self.disassemble('0f00{:02x}'.format(i*8).decode('hex'))
            self.disassemble('0f00{:02x}'.format(i*8 + 0xc0).decode('hex'))

        # 2 bytes G7
        for i in range(0, 8):
            for rm in range(0, 8):
                index = i*8 + rm
                self.disassemble('0f01{:02x}'.format(index).decode('hex'))
                self.disassemble('0f01{:02x}'.format(index + 0xc0).decode('hex'))

        # 2 bytes G8
        for i in range(0, 8):
            self.disassemble('0fba{:02x}'.format(i*8).decode('hex'))
            self.disassemble('0fba{:02x}'.format(i*8 + 0xc0).decode('hex'))

        # 2 bytes G9
        for i in range(0, 8):
            self.disassemble('0fc7{:02x}'.format(i*8).decode('hex'))
            self.disassemble('0fc7{:02x}'.format(i*8 + 0xc0).decode('hex'))
            myREX = REX()
            myREX.W = 1
            self.disassemble('{:02x}0fc7{:02x}'.format(myREX.byte(), i*8).decode('hex'))

        # 2 bytes G12
        for i in range(0, 8):
            self.disassemble('0f71{:02x}'.format(i*8).decode('hex'))
            self.disassemble('0f71{:02x}'.format(i*8 + 0xc0).decode('hex'))

        # 2 bytes G13
        for i in range(0, 8):
            self.disassemble('0f72{:02x}'.format(i*8).decode('hex'))
            self.disassemble('0f72{:02x}'.format(i*8 + 0xc0).decode('hex'))

        # 2 bytes G14
        for i in range(0, 8):
            self.disassemble('0f73{:02x}'.format(i*8).decode('hex'))
            self.disassemble('0f73{:02x}'.format(i*8 + 0xc0).decode('hex'))

        # 2 bytes G15
        for i in range(0, 8):
            self.disassemble('0fae{:02x}'.format(i*8).decode('hex'))
            self.disassemble('0fae{:02x}'.format(i*8 + 0xc0).decode('hex'))
            self.disassemble('f30fae{:02x}'.format(i*8).decode('hex'))
            self.disassemble('f30fae{:02x}'.format(i*8 + 0xc0).decode('hex'))
            self.disassemble('660fae{:02x}'.format(i*8).decode('hex'))
            self.disassemble('660fae{:02x}'.format(i*8 + 0xc0).decode('hex'))

        # 2 bytes G16
        for i in range(0, 8):
            self.disassemble('0f18{:02x}'.format(i*8).decode('hex'))
            self.disassemble('0f18{:02x}'.format(i*8 + 0xc0).decode('hex'))

        # 2 bytes G17
        for i in range(0, 8):

            myVEX = VEX('VEX.L1.0F38.W0')
            myVEX.vvvv = 0b1111
            Buffer = '{}f3{:02x}'.format(myVEX.c4(), i*8).decode('hex')
            self.disassemble(Buffer)

            myVEX = VEX('VEX.L1.0F38.W1')
            myVEX.vvvv = 0b1111
            Buffer = '{}f3{:02x}'.format(myVEX.c4(), i*8).decode('hex')
            self.disassemble(Buffer)

        # 1 byte
        self.disasmNoImm(0)
        self.disasmNoImm(1)
        self.disasmNoImm(2)
        self.disasmNoImm(3)
        self.disasmNoModrmImm8(4)
        self.disasmNoModrmImm32(5)
        self.disasmNoModrm(6)
        self.disasmNoModrm(7)
        self.disasmNoImm(8)
        self.disasmNoImm(9)
        self.disasmNoImm(0xa)
        self.disasmNoImm(0xb)
        self.disasmNoModrmImm8(0xc)
        self.disasmNoModrmImm32(0xd)
        self.disasmNoModrm(0xe)
        # 0x0f


        self.disasmNoImm(0x10)
        self.disasmNoImm(0x11)
        self.disasmNoImm(0x12)
        self.disasmNoImm(0x13)
        self.disasmNoModrmImm8(0x14)
        self.disasmNoModrmImm32(0x15)
        self.disasmNoModrm(0x16)
        self.disasmNoModrm(0x17)
        self.disasmNoImm(0x18)
        self.disasmNoImm(0x19)
        self.disasmNoImm(0x1a)
        self.disasmNoImm(0x1b)
        self.disasmNoModrmImm8(0x1c)
        self.disasmNoModrmImm32(0x1d)
        self.disasmNoModrm(0x1e)
        self.disasmNoModrm(0x1f)


        self.disasmNoImm(0x20)
        self.disasmNoImm(0x21)
        self.disasmNoImm(0x22)
        self.disasmNoImm(0x23)
        self.disasmNoModrmImm8(0x24)
        self.disasmNoModrmImm32(0x25)
        # 0x26
        self.disasmNoModrm(0x27)
        self.disasmNoImm(0x28)
        self.disasmNoImm(0x29)
        self.disasmNoImm(0x2a)
        self.disasmNoImm(0x2b)
        self.disasmNoModrmImm8(0x2c)
        self.disasmNoModrmImm32(0x2d)
        # 0x2e
        self.disasmNoModrm(0x2f)


        self.disasmNoImm(0x30)
        self.disasmNoImm(0x31)
        self.disasmNoImm(0x32)
        self.disasmNoImm(0x33)
        self.disasmNoModrmImm8(0x34)
        self.disasmNoModrmImm32(0x35)
        # 0x36
        self.disasmNoModrm(0x37)
        self.disasmNoImm(0x38)
        self.disasmNoImm(0x39)
        self.disasmNoImm(0x3a)
        self.disasmNoImm(0x3b)
        self.disasmNoModrmImm8(0x3c)
        self.disasmNoModrmImm32(0x3d)
        # 0x2e
        self.disasmNoModrm(0x3f)

        # 0x40-0x48 : REX prefixes

        for i in range(0x50, 0x60):
            self.disasmNoModrm(i)

        self.disasmNoModrm(0x60)
        self.disasmNoModrm(0x61)
        self.disasmNoModrm(0x62)
        self.disasmNoModrm(0x63)

        self.disasmNoModrmImm32(0x68)
        self.disasmImm32(0x69)
        self.disasmNoModrmImm8(0x6a)
        self.disasmImm8(0x6b)
        self.disasmNoModrm(0x6c)
        self.disasmNoModrm(0x6d)
        self.disasmNoModrm(0x6e)
        self.disasmNoModrm(0x6f)

        for i in range(0x70, 0x80):
            self.disasmNoModrmImm8(i)

        for i in range(0x84, 0x90):
            self.disasmNoImm(i)

        for i in range(0x90, 0xa0):
            self.disasmNoModrm(i)

        for i in range(0xa0, 0xa8):
            self.disasmNoModrm(i)
        self.disasmNoModrmImm8(0xa8)
        self.disasmNoModrmImm32(0xa9)
        for i in range(0xaa, 0xb0):
            self.disasmNoModrm(i)

        for i in range(0xb0, 0xb8):
            self.disasmNoModrmImm8(i)
        for i in range(0xb8, 0xc0):
            self.disasmNoModrm(i)

        self.disassemble('f30fd620'.format(i).decode('hex'))
        self.disassemble('f30fd6c0'.format(i).decode('hex'))


        self.disasm0FNoModrm(0x4)
        self.disasm0FNoModrm(0x5)
        self.disasm0FNoModrm(0x6)
        self.disasm0FNoModrm(0x7)
        self.disasm0FNoModrm(0x8)
        self.disasm0FNoModrm(0x9)
        self.disasm0FNoModrm(0xa)
        self.disasm0FNoModrm(0xb)
        self.disasm0FNoModrm(0xc)
        self.disasm0FNoImm(0xd)
        self.disasm0FNoModrm(0xe)
        self.disasm0FNoModrm(0xf)

        for i in range(0x10, 0x18):
            self.disasm0FNoImm(i)

        for i in range(0x19, 0x20):
            self.disasm0FNoImm(i)

        for i in range(0x24, 0x30):
            self.disasm0FNoImm(i)


        for i in range(0,0x77):
            self.disasmVEX0F(i)

        self.disasmVEX0FNoModrm(0x77)
        self.disasmVEX0FNoModrm(0x78)
        self.disasmVEX0FNoModrm(0x79)

        for i in range(0x7a,0x100):
            self.disasmVEX0F(i)

        # 3 bytes VEX 0F38xx
        for i in range(0,0x100):

            myVEX = VEX('VEX.NDS.0F38.W0')
            myVEX.vvvv = 0b1111
            Buffer = '{}{:02x}443322'.format(myVEX.c4(), i).decode('hex')
            self.disassemble(Buffer)

            myVEX = VEX('VEX.NDS.0F38.W1')
            myVEX.vvvv = 0b1111
            Buffer = '{}{:02x}443322'.format(myVEX.c4(), i).decode('hex')
            self.disassemble(Buffer)

            myVEX = VEX('VEX.NDS.128.66.0F38.W0')
            myVEX.vvvv = 0b1111
            Buffer = '{}{:02x}443322'.format(myVEX.c4(), i).decode('hex')
            self.disassemble(Buffer)

            myVEX = VEX('VEX.NDS.128.F2.0F38.W0')
            myVEX.vvvv = 0b1111
            Buffer = '{}{:02x}443322'.format(myVEX.c4(), i).decode('hex')
            self.disassemble(Buffer)

            myVEX = VEX('VEX.NDS.128.F3.0F38.W0')
            myVEX.vvvv = 0b1111
            Buffer = '{}{:02x}443322'.format(myVEX.c4(), i).decode('hex')
            self.disassemble(Buffer)

        # 3 bytes VEX 0F3axx
        for i in range(0,0x100):
            myVEX = VEX('VEX.NDS.128.66.0F3a.W0')
            myVEX.vvvv = 0b1111
            Buffer = '{}{:02x}443322'.format(myVEX.c4(), i).decode('hex')
            self.disassemble(Buffer)

            myVEX = VEX('VEX.NDS.128.F2.0F3a.W0')
            myVEX.vvvv = 0b1111
            Buffer = '{}{:02x}443322'.format(myVEX.c4(), i).decode('hex')
            self.disassemble(Buffer)

            myVEX = VEX('VEX.NDS.128.F3.0F3a.W0')
            myVEX.vvvv = 0b1111
            Buffer = '{}{:02x}443322'.format(myVEX.c4(), i).decode('hex')
            self.disassemble(Buffer)

        # 2 bytes EVEX 0Fxx
        for i in range(0, 0x100):
            if i != 0x38:
                myEVEX = EVEX('EVEX.128.66.0F.WIG')
                myEVEX.vvvv = 0b1111
                Buffer = '{}{:02x}443322'.format(myEVEX.prefix(), i).decode('hex')
                self.disassemble(Buffer)

                myEVEX = EVEX('EVEX.NDS.128.66.0F.W0')
                myEVEX.vvvv = 0b1111
                Buffer = '{}{:02x}443322'.format(myEVEX.prefix(), i).decode('hex')
                self.disassemble(Buffer)

                myEVEX = EVEX('EVEX.NDS.128.66.0F.W1')
                myEVEX.vvvv = 0b1111
                Buffer = '{}{:02x}443322'.format(myEVEX.prefix(), i).decode('hex')
                self.disassemble(Buffer)

                myEVEX = EVEX('EVEX.NDS.256.66.0F.W0')
                myEVEX.vvvv = 0b1111
                Buffer = '{}{:02x}443322'.format(myEVEX.prefix(), i).decode('hex')
                self.disassemble(Buffer)

                myEVEX = EVEX('EVEX.NDS.256.66.0F.W1')
                myEVEX.vvvv = 0b1111
                Buffer = '{}{:02x}443322'.format(myEVEX.prefix(), i).decode('hex')
                self.disassemble(Buffer)

                myEVEX = EVEX('EVEX.NDS.512.66.0F.W0')
                myEVEX.vvvv = 0b1111
                Buffer = '{}{:02x}443322'.format(myEVEX.prefix(), i).decode('hex')
                self.disassemble(Buffer)

                myEVEX = EVEX('EVEX.NDS.512.66.0F.W1')
                myEVEX.vvvv = 0b1111
                Buffer = '{}{:02x}443322'.format(myEVEX.prefix(), i).decode('hex')
                self.disassemble(Buffer)

                myEVEX = EVEX('EVEX.NDS.128.F2.0F.W0')
                myEVEX.vvvv = 0b1111
                Buffer = '{}{:02x}443322'.format(myEVEX.prefix(), i).decode('hex')
                self.disassemble(Buffer)

                myEVEX = EVEX('EVEX.NDS.128.F2.0F.W1')
                myEVEX.vvvv = 0b1111
                Buffer = '{}{:02x}443322'.format(myEVEX.prefix(), i).decode('hex')
                self.disassemble(Buffer)

                myEVEX = EVEX('EVEX.NDS.128.F3.0F.W0')
                myEVEX.vvvv = 0b1111
                Buffer = '{}{:02x}443322'.format(myEVEX.prefix(), i).decode('hex')
                self.disassemble(Buffer)

                myEVEX = EVEX('EVEX.NDS.128.F3.0F.W1')
                myEVEX.vvvv = 0b1111
                Buffer = '{}{:02x}443322'.format(myEVEX.prefix(), i).decode('hex')
                self.disassemble(Buffer)

        # 3 bytes EVEX 0F38xx
        for i in range(0, 0x100):
            myEVEX = EVEX('EVEX.NDS.128.66.0F38.W0')
            myEVEX.vvvv = 0b1111
            Buffer = '{}{:02x}443322'.format(myEVEX.prefix(), i).decode('hex')
            self.disassemble(Buffer)

            myEVEX = EVEX('EVEX.NDS.128.66.0F38.W1')
            myEVEX.vvvv = 0b1111
            Buffer = '{}{:02x}443322'.format(myEVEX.prefix(), i).decode('hex')
            self.disassemble(Buffer)

            myEVEX = EVEX('EVEX.NDS.128.F2.0F38.WIG')
            myEVEX.vvvv = 0b1111
            Buffer = '{}{:02x}443322'.format(myEVEX.prefix(), i).decode('hex')
            self.disassemble(Buffer)

            myEVEX = EVEX('EVEX.NDS.128.F3.0F38.WIG')
            myEVEX.vvvv = 0b1111
            Buffer = '{}{:02x}443322'.format(myEVEX.prefix(), i).decode('hex')
            self.disassemble(Buffer)

            myEVEX = EVEX('EVEX.NDS.256.66.0F38.W0')
            myEVEX.vvvv = 0b1111
            Buffer = '{}{:02x}443322'.format(myEVEX.prefix(), i).decode('hex')
            self.disassemble(Buffer)

            myEVEX = EVEX('EVEX.NDS.256.66.0F38.W1')
            myEVEX.vvvv = 0b1111
            Buffer = '{}{:02x}443322'.format(myEVEX.prefix(), i).decode('hex')
            self.disassemble(Buffer)

            myEVEX = EVEX('EVEX.NDS.256.F2.0F38.WIG')
            myEVEX.vvvv = 0b1111
            Buffer = '{}{:02x}443322'.format(myEVEX.prefix(), i).decode('hex')
            self.disassemble(Buffer)

            myEVEX = EVEX('EVEX.NDS.256.F3.0F38.WIG')
            myEVEX.vvvv = 0b1111
            Buffer = '{}{:02x}443322'.format(myEVEX.prefix(), i).decode('hex')
            self.disassemble(Buffer)

            myEVEX = EVEX('EVEX.NDS.512.66.0F38.W0')
            myEVEX.vvvv = 0b1111
            Buffer = '{}{:02x}443322'.format(myEVEX.prefix(), i).decode('hex')
            self.disassemble(Buffer)

            myEVEX = EVEX('EVEX.NDS.512.66.0F38.W1')
            myEVEX.vvvv = 0b1111
            Buffer = '{}{:02x}443322'.format(myEVEX.prefix(), i).decode('hex')
            self.disassemble(Buffer)

            myEVEX = EVEX('EVEX.NDS.512.F2.0F38.WIG')
            myEVEX.vvvv = 0b1111
            Buffer = '{}{:02x}443322'.format(myEVEX.prefix(), i).decode('hex')
            self.disassemble(Buffer)

            myEVEX = EVEX('EVEX.NDS.512.F3.0F38.WIG')
            myEVEX.vvvv = 0b1111
            Buffer = '{}{:02x}443322'.format(myEVEX.prefix(), i).decode('hex')
            self.disassemble(Buffer)

        # 3 bytes EVEX 0F3axx
        for i in range(0, 0x100):
            myEVEX = EVEX('EVEX.NDS.128.66.0F3a.W0')
            myEVEX.vvvv = 0b1111
            Buffer = '{}{:02x}443322'.format(myEVEX.prefix(), i).decode('hex')
            self.disassemble(Buffer)

            myEVEX = EVEX('EVEX.NDS.128.66.0F3a.W1')
            myEVEX.vvvv = 0b1111
            Buffer = '{}{:02x}443322'.format(myEVEX.prefix(), i).decode('hex')
            self.disassemble(Buffer)

            myEVEX = EVEX('EVEX.NDS.128.F2.0F3a.WIG')
            myEVEX.vvvv = 0b1111
            Buffer = '{}{:02x}443322'.format(myEVEX.prefix(), i).decode('hex')
            self.disassemble(Buffer)

            myEVEX = EVEX('EVEX.NDS.128.F3.0F3a.WIG')
            myEVEX.vvvv = 0b1111
            Buffer = '{}{:02x}443322'.format(myEVEX.prefix(), i).decode('hex')
            self.disassemble(Buffer)


    def test(self):

        # SecurityBlock is not useful if equal to buffer length

        Buffer = '0f381c28'.decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.infos.SecurityBlock = len(Buffer)
        myDisasm.read()
        assert_equal(myDisasm.length, 4)
        assert_equal(myDisasm.infos.Instruction.Opcode, 0xf381c)
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'pabsb ')

        # SecurityBlock is disabled if equal to zero

        Buffer = '0f381c28'.decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.infos.SecurityBlock = 0
        myDisasm.read()
        assert_equal(myDisasm.length, 4)
        assert_equal(myDisasm.infos.Instruction.Opcode, 0xf381c)
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'pabsb ')

        # SecurityBlock blocking analysis if < buffer length

        for i in range(1, len(Buffer)):
            myDisasm = Disasm(Buffer)
            myDisasm.infos.SecurityBlock = i
            myDisasm.read()
            assert_equal(myDisasm.length, OUT_OF_BLOCK)

        # SecurityBlock if MOD == 0 and RM = 5

        Buffer = '0f381c0501000000'.decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.infos.SecurityBlock = len(Buffer)
        myDisasm.infos.VirtualAddr = 0x400000
        myDisasm.read()
        assert_equal(myDisasm.length, 8)
        assert_equal(myDisasm.infos.Instruction.Opcode, 0xf381c)
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'pabsb ')
        assert_equal(myDisasm.infos.repr, 'pabsb mm0, qword ptr [0000000000400009h]')

        for i in range(1, len(Buffer)):
            myDisasm = Disasm(Buffer)
            myDisasm.infos.SecurityBlock = i
            myDisasm.read()
            assert_equal(myDisasm.length, OUT_OF_BLOCK)

        # SecurityBlock if MOD == 1 (disp8)

        Buffer = '660f381c6b11'.decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.infos.SecurityBlock = len(Buffer)
        myDisasm.read()
        assert_equal(myDisasm.length, 6)

        for i in range(1, len(Buffer)):
            myDisasm = Disasm(Buffer)
            myDisasm.infos.SecurityBlock = i
            myDisasm.read()
            assert_equal(myDisasm.length, OUT_OF_BLOCK)

        # SecurityBlock if MOD == 1 (disp8) and RM == 4 (SIB enabled)

        myVEX = VEX('VEX.128.66.0F38.WIG')
        myVEX.vvvv = 0b1111
        Buffer = '{}1c443322'.format(myVEX.c4()).decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.infos.SecurityBlock = len(Buffer) - 1
        myDisasm.read()
        assert_equal(myDisasm.length, OUT_OF_BLOCK)

        myVEX = VEX('VEX.128.66.0F38.WIG')
        myVEX.vvvv = 0b1111
        Buffer = '{}1c443322'.format(myVEX.c4()).decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.infos.SecurityBlock = len(Buffer)
        myDisasm.read()
        assert_equal(myDisasm.length, 7)

        # SecurityBlock if MOD == 2 (disp32)

        myVEX = VEX('VEX.128.66.0F38.WIG')
        myVEX.vvvv = 0b1111
        Buffer = '{}1c843311223344'.format(myVEX.c4()).decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.infos.SecurityBlock = len(Buffer) - 1
        offset = myDisasm.infos.offset
        myDisasm.read()
        assert_equal(myDisasm.length, OUT_OF_BLOCK)
        assert_equal(myDisasm.infos.Reserved_.EIP_ - offset, myDisasm.infos.SecurityBlock)
        assert_equal(myDisasm.infos.Operand1.Memory.Displacement, 0)

        myVEX = VEX('VEX.128.66.0F38.WIG')
        myVEX.vvvv = 0b1111
        Buffer = '{}1c843311223344'.format(myVEX.c4()).decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.infos.SecurityBlock = len(Buffer)
        myDisasm.read()
        assert_equal(myDisasm.length, 10)
        assert_equal(myDisasm.infos.Instruction.Opcode, 0x1c)
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'vpabsb ')
        assert_equal(myDisasm.infos.repr, 'vpabsb xmm8, xmmword ptr [r11+r14+44332211h]')

        Buffer = '40034d03'.decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.infos.SecurityBlock = 2
        myDisasm.infos.VirtualAddr = 0x400000
        offset = myDisasm.infos.offset
        myDisasm.read()
        assert_equal(myDisasm.length, OUT_OF_BLOCK)
        assert_equal(myDisasm.infos.Reserved_.EIP_ - offset, 3)
        assert_equal(myDisasm.infos.Reserved_.MOD_, 0)
        assert_equal(myDisasm.infos.Reserved_.RM_, 0)


        Buffer = '40034d03'.decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.infos.SecurityBlock = 1
        myDisasm.infos.VirtualAddr = 0x400000
        offset = myDisasm.infos.offset
        myDisasm.read()
        assert_equal(myDisasm.length, OUT_OF_BLOCK)
        assert_equal(myDisasm.infos.Reserved_.EIP_ - offset, 0)
        assert_equal(myDisasm.infos.Reserved_.MOD_, 0)
        assert_equal(myDisasm.infos.Reserved_.RM_, 0)

        Buffer = '660f3a14443322'.decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.infos.SecurityBlock = 4
        myDisasm.infos.VirtualAddr = 0x400000
        offset = myDisasm.infos.offset
        myDisasm.read()
        assert_equal(myDisasm.length, OUT_OF_BLOCK)
        assert_equal(myDisasm.infos.Reserved_.MOD_, 0)
        assert_equal(myDisasm.infos.Reserved_.RM_, 0)
        assert_equal(myDisasm.infos.Reserved_.EIP_ - offset, 3)

        Buffer = 'e811223344'.decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.infos.SecurityBlock = 4
        myDisasm.infos.VirtualAddr = 0x400000
        offset = myDisasm.infos.offset
        myDisasm.read()
        assert_equal(myDisasm.length, OUT_OF_BLOCK)
        assert_equal(myDisasm.infos.Reserved_.EIP_ - offset, 0)

        Buffer = '691011223344'.decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.infos.SecurityBlock = 5
        offset = myDisasm.infos.offset
        myDisasm.read()
        assert_equal(myDisasm.length, OUT_OF_BLOCK)
        assert_equal(myDisasm.infos.Reserved_.EIP_ - offset, 2)
        assert_equal(myDisasm.infos.Instruction.Opcode, 0x69)
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'imul ')
        assert_equal(myDisasm.infos.Instruction.Immediat, 0)

        Buffer = '6b1011'.decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.infos.SecurityBlock = 2
        offset = myDisasm.infos.offset
        myDisasm.read()
        assert_equal(myDisasm.length, OUT_OF_BLOCK)
        assert_equal(myDisasm.infos.Reserved_.EIP_ - offset, 2)
        assert_equal(myDisasm.infos.Instruction.Opcode, 0x6b)
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'imul ')
        assert_equal(myDisasm.infos.Instruction.Immediat, 0)

        Buffer = '691011223344'.decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.infos.SecurityBlock = len(Buffer)
        myDisasm.infos.VirtualAddr = 0x400000
        offset = myDisasm.infos.offset
        myDisasm.read()
        assert_equal(myDisasm.length, 6)
        assert_equal(myDisasm.infos.Reserved_.EIP_ - offset, 6)
        assert_equal(myDisasm.infos.Instruction.Opcode, 0x69)
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'imul ')
        assert_equal(myDisasm.infos.Instruction.Immediat, 0x44332211)


        # if SecurityBlock > 15, it is disabled and max size is set to 15
        Buffer = '666666666666666666666666666690'.decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.infos.SecurityBlock = 18
        myDisasm.infos.VirtualAddr = 0x400000
        offset = myDisasm.infos.offset
        myDisasm.read()
        assert_equal(myDisasm.length, 15)
        assert_equal(myDisasm.infos.Reserved_.EIP_ - offset, 15)
        assert_equal(myDisasm.infos.Instruction.Opcode, 0x90)
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'nop ')


        Buffer = '0f8001000000'.decode('hex')
        myDisasm = Disasm(Buffer)
        myDisasm.infos.SecurityBlock = len(Buffer)
        myDisasm.infos.VirtualAddr = 0x400000
        offset = myDisasm.infos.offset
        myDisasm.read()
        assert_equal(myDisasm.length, 6)
        assert_equal(myDisasm.infos.Instruction.Opcode, 0x0f80)
        assert_equal(myDisasm.infos.Instruction.Mnemonic, 'jo ')
