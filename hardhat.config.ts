// @ts-nocheck
// hardhat.config.ts

import 'dotenv/config';
import '@nomiclabs/hardhat-etherscan';
import '@nomiclabs/hardhat-solhint';
import '@tenderly/hardhat-tenderly';
import '@nomiclabs/hardhat-waffle';
import 'hardhat-abi-exporter';
import 'hardhat-deploy';
import 'hardhat-deploy-ethers';
import 'hardhat-gas-reporter';
import 'hardhat-spdx-license-identifier';
import '@typechain/hardhat';
import 'hardhat-watcher';
import 'solidity-coverage';
import './tasks';

import {HardhatUserConfig} from 'hardhat/types';
import {removeConsoleLog} from 'hardhat-preprocessor';

const accounts = {
    mnemonic: process.env.MNEMONIC || 'test test test test test test test test test test test junk',
    // accountsBalance: "990000000000000000000",
};

const config: HardhatUserConfig = {
    abiExporter: {
        path: './abi',
        clear: false,
        flat: true,
        // only: [],
        // except: []
    },
    defaultNetwork: 'harmony',
    etherscan: {
        apiKey: process.env.ETHERSCAN_API_KEY,
    },
    gasReporter: {
        coinmarketcap: process.env.COINMARKETCAP_API_KEY,
        currency: 'USD',
        enabled: process.env.REPORT_GAS === 'true',
        excludeContracts: ['contracts/mocks/', 'contracts/libraries/'],
    },
    mocha: {
        timeout: 20000,
    },
    namedAccounts: {
        deployer: {
            default: 0,
        },
        dev: {
            default: '0xDb69e513FFf3cD48a441fAC61bcA1E0e0FC9707c',
        },
    },
    networks: {
        mainnet: {
            url: `https://mainnet.infura.io/v3/${process.env.INFURA_API_KEY}`,
            accounts,
            gasPrice: 6 * 1000000000,
            chainId: 1,
        },
        localhost: {
            live: false,
            accounts,
            saveDeployments: true,
            tags: ['local'],
        },
        hardhat: {
            forking: {
                enabled: process.env.FORKING === 'true',
                url: `https://eth-mainnet.alchemyapi.io/v2/${process.env.ALCHEMY_API_KEY}`,
            },
            live: false,
            saveDeployments: true,
            tags: ['test', 'local'],
        },
        ropsten: {
            url: `https://ropsten.infura.io/v3/${process.env.INFURA_API_KEY}`,
            accounts,
            chainId: 3,
            live: true,
            saveDeployments: true,
            tags: ['staging'],
            gasPrice: 5000000000,
        },
        rinkeby: {
            url: `https://rinkeby.infura.io/v3/${process.env.INFURA_API_KEY}`,
            accounts,
            chainId: 4,
            live: true,
            saveDeployments: true,
            tags: ['staging'],
            gasPrice: 5000000000,
        },
        coinnet: {
            url: `https://data.1coin.network`,
            accounts,
            chainId: 85,
            live: true,
            saveDeployments: true,
            gasPrice: 1 * 1000000000,
        },
        goerli: {
            url: `https://goerli.infura.io/v3/${process.env.INFURA_API_KEY}`,
            accounts,
            chainId: 5,
            live: true,
            saveDeployments: true,
            tags: ['staging'],
            gasPrice: 5000000000,
            gasMultiplier: 2,
        },
        kovan: {
            url: `https://kovan.infura.io/v3/${process.env.INFURA_API_KEY}`,
            accounts,
            chainId: 42,
            live: true,
            saveDeployments: true,
            tags: ['staging'],
            gasPrice: 20000000000,
            gasMultiplier: 2,
        },
        moonbase: {
            url: 'https://rpc.testnet.moonbeam.network',
            accounts,
            chainId: 1287,
            live: true,
            saveDeployments: true,
            tags: ['staging'],
            gas: 5198000,
            gasMultiplier: 2,
        },
        fantom: {
            url: 'https://rpcapi.fantom.network',
            accounts,
            chainId: 250,
            live: true,
            saveDeployments: true,
        },
        'fantom-testnet': {
            url: 'https://rpc.testnet.fantom.network',
            accounts,
            chainId: 4002,
            live: true,
            saveDeployments: true,
            tags: ['staging'],
            gasMultiplier: 2,
        },
        matic: {
            url: 'https://rpc-mainnet.maticvigil.com',
            accounts,
            chainId: 137,
            live: true,
            saveDeployments: true,
        },
        mumbai: {
            url: 'https://rpc-mumbai.maticvigil.com/',
            accounts,
            chainId: 80001,
            live: true,
            saveDeployments: true,
            tags: ['staging'],
            gasMultiplier: 2,
        },
        xdai: {
            url: 'https://rpc.xdaichain.com',
            accounts,
            chainId: 100,
            live: true,
            saveDeployments: true,
        },
        bsc: {
            url: 'https://bsc-dataseed.binance.org',
            accounts,
            chainId: 56,
            live: true,
            gasPrice: 5 * 1000000000,
            saveDeployments: true,
        },
        'bsc-testnet': {
            url: 'https://data-seed-prebsc-1-s1.binance.org:8545',
            accounts,
            chainId: 97,
            live: true,
            saveDeployments: true,
            tags: ['staging'],
            // gasPrice: 10 * 1000000000,
            gasMultiplier: 2,
        },
        heco: {
            url: 'https://http-mainnet.hecochain.com',
            accounts,
            chainId: 128,
            live: true,
            saveDeployments: true,
        },
        'heco-testnet': {
            url: 'https://http-testnet.hecochain.com',
            accounts,
            chainId: 256,
            live: true,
            saveDeployments: true,
            tags: ['staging'],
            gasMultiplier: 2,
        },
        avalanche: {
            url: 'https://api.avax.network/ext/bc/C/rpc',
            accounts,
            chainId: 43114,
            live: true,
            saveDeployments: true,
            gasPrice: 25000000000,
        },
        fuji: {
            url: 'https://api.avax-test.network/ext/bc/C/rpc',
            accounts,
            chainId: 43113,
            live: true,
            saveDeployments: true,
            tags: ['staging'],
            gasMultiplier: 2,
        },
        harmony: {
            url: 'https://api.s0.t.hmny.io',
            accounts,
            chainId: 1666600000,
            live: true,
            saveDeployments: true,
        },
        'harmony-testnet': {
            url: 'https://api.s0.b.hmny.io',
            accounts,
            chainId: 1666700000,
            live: true,
            saveDeployments: true,
            tags: ['staging'],
            gasMultiplier: 2,
        },
        okex: {
            url: 'https://exchainrpc.okex.org',
            accounts,
            chainId: 66,
            live: true,
            saveDeployments: true,
        },
        'okex-testnet': {
            url: 'https://exchaintestrpc.okex.org',
            accounts,
            chainId: 65,
            live: true,
            saveDeployments: true,
            tags: ['staging'],
            gasMultiplier: 2,
        },
        arbitrum: {
            url: 'https://arb1.arbitrum.io/rpc',
            accounts,
            chainId: 42161,
            live: true,
            saveDeployments: true,
            blockGasLimit: 700000,
        },
        'arbitrum-testnet': {
            url: 'https://kovan3.arbitrum.io/rpc',
            accounts,
            chainId: 79377087078960,
            live: true,
            saveDeployments: true,
            tags: ['staging'],
            gasMultiplier: 2,
        },
    },
    paths: {
        artifacts: 'artifacts',
        cache: 'cache',
        deploy: 'deploy',
        deployments: 'deployments',
        imports: 'imports',
        sources: 'contracts',
        tests: 'test',
    },
    preprocess: {
        eachLine: removeConsoleLog((bre) => bre.network.name !== 'hardhat' && bre.network.name !== 'localhost'),
    },
    solidity: {
        compilers: [
            {
                version: '0.6.12',
                settings: {
                    optimizer: {
                        enabled: true,
                        runs: 200,
                    },
                },
            },
        ],
    },
    spdxLicenseIdentifier: {
        overwrite: false,
        runOnCompile: true,
    },
    tenderly: {
        project: process.env.TENDERLY_PROJECT!,
        username: process.env.TENDERLY_USERNAME!,
    },
    typechain: {
        outDir: 'types',
        target: 'ethers-v5',
    },
    watcher: {
        compile: {
            tasks: ['compile'],
            files: ['./contracts'],
            verbose: true,
        },
    },
};

const fs = require("fs")

function getSortedFiles(dependenciesGraph) {
    const tsort = require("tsort")
    const graph = tsort()

    const filesMap = {}
    const resolvedFiles = dependenciesGraph.getResolvedFiles()
    resolvedFiles.forEach((f) => (filesMap[f.sourceName] = f))

    for (const [from, deps] of dependenciesGraph.entries()) {
        for (const to of deps) {
            graph.add(to.sourceName, from.sourceName)
        }
    }

    const topologicalSortedNames = graph.sort()

    // If an entry has no dependency it won't be included in the graph, so we
    // add them and then dedup the array
    const withEntries = topologicalSortedNames.concat(resolvedFiles.map((f) => f.sourceName))

    const sortedNames = [...new Set(withEntries)]
    return sortedNames.map((n) => filesMap[n])
}

function getFileWithoutImports(resolvedFile) {
    const IMPORT_SOLIDITY_REGEX = /^\s*import(\s+)[\s\S]*?;\s*$/gm

    return resolvedFile.content.rawContent.replace(IMPORT_SOLIDITY_REGEX, "").trim()
}

subtask("flat:get-flattened-sources", "Returns all contracts and their dependencies flattened")
    .addOptionalParam("files", undefined, undefined, types.any)
    .addOptionalParam("output", undefined, undefined, types.string)
    .setAction(async ({ files, output }, { run }) => {
        const dependencyGraph = await run("flat:get-dependency-graph", { files })
        console.log(dependencyGraph)

        let flattened = ""

        if (dependencyGraph.getResolvedFiles().length === 0) {
            return flattened
        }

        const sortedFiles = getSortedFiles(dependencyGraph)

        let isFirst = true
        for (const file of sortedFiles) {
            if (!isFirst) {
                flattened += "\n"
            }
            flattened += `// File ${file.getVersionedName()}\n`
            flattened += `${getFileWithoutImports(file)}\n`

            isFirst = false
        }

        // Remove every line started with "// SPDX-License-Identifier:"
        flattened = flattened.replace(/SPDX-License-Identifier:/gm, "License-Identifier:")

        flattened = `// SPDX-License-Identifier: MIXED\n\n${flattened}`

        // Remove every line started with "pragma experimental ABIEncoderV2;" except the first one
        flattened = flattened.replace(/pragma experimental ABIEncoderV2;\n/gm, ((i) => (m) => (!i++ ? m : ""))(0))

        flattened = flattened.trim()
        if (output) {
            console.log("Writing to", output)
            fs.writeFileSync(output, flattened)
            return ""
        }
        return flattened
    })

subtask("flat:get-dependency-graph")
    .addOptionalParam("files", undefined, undefined, types.any)
    .setAction(async ({ files }, { run }) => {
        const sourcePaths = files === undefined ? await run("compile:solidity:get-source-paths") : files.map((f) => fs.realpathSync(f))

        const sourceNames = await run("compile:solidity:get-source-names", {
            sourcePaths,
        })

        const dependencyGraph = await run("compile:solidity:get-dependency-graph", { sourceNames })

        return dependencyGraph
    })

task("flat", "Flattens and prints contracts and their dependencies")
    .addOptionalVariadicPositionalParam("files", "The files to flatten", undefined, types.inputFile)
    .addOptionalParam("output", "Specify the output file", undefined, types.string)
    .setAction(async ({ files, output }, { run }) => {
        console.log(
            await run("flat:get-flattened-sources", {
                files,
                output,
            })
        )
    })

export default config;
