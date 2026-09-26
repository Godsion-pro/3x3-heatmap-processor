// UVM-style C++ testbench for the 3x3 heatmap processor (Verilator)
//   TopTxDriver  -> DUT(top) -> TopMonitor
//        |                          |
//     TopInTx                    TopOutTx
//        \------> TopScoreboard <---/   (golden model: 인접 코어 평균)

#include <verilated.h>
#include <verilated_vcd_c.h>
#include "Vtop.h"
#include <verilated_cov.h>

#include <iostream>
#include <vector>
#include <deque>
#include <cstdlib>
#include <ctime>

#define MAX_SIM_TIME 4000
vluint64_t sim_time = 0;

// === Input Transaction ===
class TopInTx {
public:
  uint8_t temp_val;
};

// === Output Transaction ===
class TopOutTx {
public:
  uint8_t heat[9];
};

// === Scoreboard ===
class TopScoreboard {
private:
  std::vector<uint8_t> input_vals;  // 입력값 9개 저장
  bool captured = false;

public:
  void writeIn(TopInTx* tx) {
    if (input_vals.size() < 9)  // 최대 9개까지 저장 (0~8 인덱스)
      input_vals.push_back(tx->temp_val);
    delete tx;
  }

  std::vector<uint8_t> writeOut(TopOutTx* tx) {
    if (input_vals.size() < 9) {
      std::cerr << "[SCB ERROR] Not enough input values captured (expected 9, got "
                << input_vals.size() << ")\n";
      exit(1);
    }

    const auto& h = input_vals;
    int expected[10] = {
      0,
      (h[7] + h[3] + h[8]) / 3,
      (h[4] + h[6] + h[7] + h[8]) / 4,
      (h[5] + h[6] + h[7]) / 3,
      (h[0] + h[5] + h[4] + h[6]) / 4,
      (h[3] + h[4] + h[1] + h[5] + h[7]) / 5,
      (h[2] + h[3] + h[4] + h[8]) / 4,
      (h[1] + h[2] + h[3]) / 3,
      (h[0] + h[1] + h[2] + h[4]) / 4,
      (h[0] + h[1] + h[5]) / 3
    };

    //다음 cycle을 위한 output
    std::vector<uint8_t> out_values(9);
    out_values[0] = (h[7] + h[3] + h[8]) / 3;
    out_values[1] = (h[4] + h[6] + h[7] + h[8]) / 4;
    out_values[2] = (h[5] + h[6] + h[7]) / 3;
    out_values[3] = (h[0] + h[5] + h[4] + h[6]) / 4;
    out_values[4] = (h[3] + h[4] + h[1] + h[5] + h[7]) / 5;
    out_values[5] = (h[2] + h[3] + h[4] + h[8]) / 4;
    out_values[6] = (h[1] + h[2] + h[3]) / 3;
    out_values[7] = (h[0] + h[1] + h[2] + h[4]) / 4;
    out_values[8] = (h[0] + h[1] + h[5]) / 3;

    bool pass = true;
    for (int i = 1; i <= 9; ++i) {
      if (tx->heat[i - 1] != expected[i]) {
        std::cout << "[SCB] Core" << i
                  << " mismatch: expected=" << +expected[i]
                  << ", actual=" << +tx->heat[i - 1] << "\n";
        pass = false;
      }
    }

    if (pass) {
      std::cout << "[SCB] 1st!!! All outputs matched expected values.\n";
      for (int i = 1; i <= 9; ++i) {
        std::cout << "[SCB] Core" << i
                  << " match: expected=" << +expected[i]
                  << ", actual=" << +tx->heat[i - 1] << "\n";
      }
    }

    delete tx;
    return out_values;
  }

  // ---------------------------------------------------------- cycle 2
  std::vector<uint8_t> writeOut_cycle2(TopOutTx* tx, std::vector<uint8_t> expected1) {
    const auto& h = expected1;

    int expected2[10] = {
      0,
      (h[0] + h[1] + h[5]) / 3,
      (h[0] + h[1] + h[2] + h[4]) / 4,
      (h[1] + h[2] + h[3]) / 3,
      (h[2] + h[3] + h[4] + h[8]) / 4,
      (h[1] + h[3] + h[4] + h[5] + h[7]) / 5,
      (h[0] + h[4] + h[5] + h[6]) / 4,
      (h[5] + h[6] + h[7]) / 3,
      (h[4] + h[6] + h[7] + h[8]) / 4,
      (h[3] + h[7] + h[8]) / 3
    };

    //다음 cycle을 위한 output
    std::vector<uint8_t> out_values(9);
    for (int i = 0; i < 9; ++i) out_values[i] = expected2[i + 1];

    bool pass = true;
    for (int i = 1; i <= 9; ++i) {
      if (tx->heat[i - 1] != expected2[i]) {
        std::cout << "[SCB] Core" << i
                  << " mismatch: expected=" << +expected2[i]
                  << ", actual=" << +tx->heat[i - 1] << "\n";
        pass = false;
      }
    }

    if (pass) {
      std::cout << "[SCB] 2nd cycle !!!!  All outputs matched expected values.\n";
      for (int i = 1; i <= 9; ++i) {
        std::cout << "[SCB] Core" << i
                  << " match: expected=" << +expected2[i]
                  << ", actual=" << +tx->heat[i - 1] << "\n";
      }
    }

    delete tx;
    return out_values;
  }

  // ---------------------------------------------------------- cycle 3
  void writeOut_cycle3(TopOutTx* tx, std::vector<uint8_t> expected2) {
    const auto& h = expected2;

    int expected3[10] = {
      0,
      (h[0] + h[1] + h[5]) / 3,
      (h[0] + h[1] + h[2] + h[4]) / 4,
      (h[1] + h[2] + h[3]) / 3,
      (h[2] + h[3] + h[4] + h[8]) / 4,
      (h[1] + h[3] + h[4] + h[5] + h[7]) / 5,
      (h[0] + h[4] + h[5] + h[6]) / 4,
      (h[5] + h[6] + h[7]) / 3,
      (h[4] + h[6] + h[7] + h[8]) / 4,
      (h[3] + h[7] + h[8]) / 3
    };

    bool pass = true;
    for (int i = 1; i <= 9; ++i) {
      if (tx->heat[i - 1] != expected3[i]) {
        std::cout << "[SCB] Core" << i
                  << " mismatch: expected=" << +expected3[i]
                  << ", actual=" << +tx->heat[i - 1] << "\n";
        pass = false;
      }
    }

    if (pass) {
      std::cout << "[SCB] 3rd cycle !!!!  All outputs matched expected values.\n";
      for (int i = 1; i <= 9; ++i) {
        std::cout << "[SCB] Core" << i
                  << " match: expected=" << +expected3[i]
                  << ", actual=" << +tx->heat[i - 1] << "\n";
      }
    }

    delete tx;
  }
};

// === TX (Driver) ===
class TopTxDriver {
private:
  Vtop* dut;
  std::vector<TopInTx*> input_vec;

public:
  int idx = 0;

  TopTxDriver(Vtop* dut) : dut(dut) {
    // Generate 9 random inputs
    std::srand(std::time(0));
    for (int i = 0; i < 9; ++i) {
      TopInTx* tx = new TopInTx();
      tx->temp_val = std::rand() % 10;
      input_vec.push_back(tx);
    }
  }

  void drive(TopScoreboard* scb) {
    if (idx < 9) {
      dut->temp_val = input_vec[idx]->temp_val;
      scb->writeIn(input_vec[idx]); // Scoreboard takes ownership
      std::cout << "input temp_val[" << idx << "] = " << +dut->temp_val << "\n";
      ++idx;
    } else {
      dut->temp_val = 0;
    }
  }
};

// === Output Monitor ===
class TopMonitor {
private:
  Vtop* dut;

public:
  TopMonitor(Vtop* dut) : dut(dut) {}

  TopOutTx* capture() {
    TopOutTx* tx = new TopOutTx();
    tx->heat[0] = dut->heat1;
    tx->heat[1] = dut->heat2;
    tx->heat[2] = dut->heat3;
    tx->heat[3] = dut->heat4;
    tx->heat[4] = dut->heat5;
    tx->heat[5] = dut->heat6;
    tx->heat[6] = dut->heat7;
    tx->heat[7] = dut->heat8;
    tx->heat[8] = dut->heat9;
    return tx;
  }
};

void reset_dut(Vtop* dut) {
  if (sim_time < 20) {
    dut->reset_n = 0;
  }
  else {
    dut->reset_n = 1;
  }
}

int main(int argc, char** argv) {
  Verilated::commandArgs(argc, argv);
  Vtop* dut = new Vtop;
  VerilatedVcdC* tfp = new VerilatedVcdC;
  Verilated::traceEverOn(true);
  dut->trace(tfp, 99);
  tfp->open("waveform.vcd");

  TopScoreboard scb;
  TopTxDriver tx(dut);
  TopMonitor monitor(dut);

  dut->clk = 0;
  dut->reset_n = 0;
  dut->temp_val = 0;

  std::vector<uint8_t> result_1st(9);
  std::vector<uint8_t> result_2nd(9);
  while (sim_time < MAX_SIM_TIME) {
    reset_dut(dut);

    // Toggle clock
    dut->clk = !dut->clk;
    dut->eval();

    // On rising edge
    if (dut->clk == 1) {
      if (sim_time >= 20 && tx.idx < 9) {
        tx.drive(&scb);
      }

      if (sim_time == 350) {  //1st cycle
        TopOutTx* tx_out1 = monitor.capture();
        result_1st = scb.writeOut(tx_out1);
        std::cout << "\n";
      }

      else if (sim_time == 560) { //2nd cycle
        TopOutTx* tx_out2 = monitor.capture();
        result_2nd = scb.writeOut_cycle2(tx_out2, result_1st);
        std::cout << "\n";
      }

      else if (sim_time == 770) { //3rd cycle
        TopOutTx* tx_out3 = monitor.capture();
        scb.writeOut_cycle3(tx_out3, result_2nd);
        std::cout << "\n";
      }
    }

    tfp->dump(sim_time);
    sim_time += 5;
  }

  tfp->close();

  // 커버리지 카운터는 모델 내부에 있으므로 delete dut 이전에 기록해야 함
  VerilatedCov::write("coverage.dat");

  delete dut;
  delete tfp;

  return 0;
}
