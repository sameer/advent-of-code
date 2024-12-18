use std::u64;

use rayon::iter::{IntoParallelIterator, ParallelIterator};

const PROGRAM: [u8; 16] = [2, 4, 1, 6, 7, 5, 4, 6, 1, 4, 5, 5, 0, 3, 3, 0];
fn main() {
    let final_a = (6617148600..281474976710656)
        .into_par_iter()
        .find_any(|a| execute(*a))
        // .enumerate()
        // .inspect(|(i, a)| {
        //     if i % 10_000_000 == 0 {
        //         println!("{a}");
        //     }
        // })
        // .find(|(_, a)| execute(*a))
        .unwrap();
    dbg!(final_a);
}

#[inline]
fn execute(mut a: u64) -> bool {
    for expected in PROGRAM {
        let intermediate_b = (a & 7) ^ 6;
        let b = (intermediate_b ^ (a >> intermediate_b)) ^ 4;

        let actual = b as u8;
        if expected != actual {
            return false;
        }

        a >>= 3;

        if a == 0 {
            return true;
        }
    }

    unreachable!()
}
