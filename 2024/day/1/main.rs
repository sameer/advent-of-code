use std::collections::HashMap;
use std::convert::TryInto;

fn main() {
    let input = std::fs::read_to_string("input").unwrap();
    let parsed = input
        .lines()
        .filter(|l| l.contains("   "))
        .map(|l| {
            l.split("   ")
                .map(|x| x.parse::<usize>().unwrap())
                .collect::<Vec<_>>()
                .try_into()
                .unwrap()
        })
        .collect::<Vec<[usize; 2]>>();
    let mut left = Vec::with_capacity(parsed.len());
    let mut right = Vec::with_capacity(parsed.len());
    parsed.into_iter().for_each(|[l, r]| {
        left.push(l);
        right.push(r);
    });
    left.sort();
    right.sort();

    let sum: usize = left
        .iter()
        .copied()
        .zip(right.iter().copied())
        .map(|(l, r)| l.abs_diff(r))
        .sum();

    println!("{sum}");

    // Part 2
    let mut right_freq: HashMap<usize, usize> = HashMap::with_capacity(right.len());
    right.into_iter().for_each(|r| {
        *right_freq.entry(r).or_default() += 1;
    });

    let similarity_score = left
        .into_iter()
        .map(|l| l * right_freq.get(&l).copied().unwrap_or_default())
        .sum::<usize>();
    println!("{similarity_score}");
}
