module MyModule::BasicStaking {

    use aptos_framework::signer;
    use aptos_framework::coin;
    use aptos_framework::aptos_coin::AptosCoin;

    /// Struct representing the staking information.
    struct StakingPool has store, key {
        total_staked: u64,
        reward_rate: u64,  // Reward rate per staked token
    }

    /// Function to create a staking pool with a specific reward rate.
    public fun create_pool(owner: &signer, reward_rate: u64) {
        let pool = StakingPool {
            total_staked: 0,
            reward_rate,
        };
        move_to(owner, pool);
    }

    /// Function for users to stake tokens and receive rewards based on the staking amount.
    public fun stake(staker: &signer, pool_owner: address, amount: u64) acquires StakingPool {
        let pool = borrow_global_mut<StakingPool>(pool_owner);

        // Stake tokens
        let stake_amount = coin::withdraw<AptosCoin>(staker, amount);
        coin::deposit<AptosCoin>(pool_owner, stake_amount);

        // Calculate and distribute rewards based on the reward rate
        let rewards = (amount * pool.reward_rate);
        let reward_transfer = coin::withdraw<AptosCoin>(staker, rewards);
        coin::deposit<AptosCoin>(signer::address_of(staker), reward_transfer);

        // Update total staked
        pool.total_staked = pool.total_staked + amount;
    }
}
