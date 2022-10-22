const fs = require('fs')

const artistNames = [
  'Calicho Arevalo',
  'Alana McCarthy',
  'Samantha Pordes',
  'Martin Aveling',
  'Nahuel Bardi',
  'Callum Pickard',
  'Joel Ntm',
  'Carlos Nieto',
  'Neda Mamo',
  'Angga Tantama',
  'Jaye Kang',
  'Iqbal Hakim Boo',
]

const animals = [
  'Bee',
  'Bee',
  'Ant',
  'Octopus',
  'Octopus',
  'Ant',
  'Octopus',
  'Bee',
  'Bee',
  'Ant',
  'Ant',
  'Octopus'
]

const BASE_URI = ''

const outputDir = `membership_nft_metadata/`
if (!fs.existsSync(outputDir)) {
  fs.mkdirSync(outputDir, { recursive: true })
} else {
  fs.rmdir(`membership_nft_metadata/`, () => {})
}
for (let i = 1; i <= 2232; i++) {
  let rarity
  let artist
  let animal
  if (i <= 12) {
    animal = animals[i % 12]
    artist = artistNames[i % 12]
    rarity = {
      type: 'string',
      value: 'Mycelia',
      description:
        'Valorize Mycelia NFTs are a collection of 12 1 of 1 NFTs each made by a different gifted artist. They grant you the benefits described in the benefits property',
      benefits: [
        'An NFT that is part of the most unique collection of art in NFT history',
        'The highest amount of quarterly $VALOR token airdrops',
        'Access to the exclusive membership section of the ValorizeDAO discord',
        'Free access to our upcoming Tokenomics Academy Course',
      ],
    }
  } else if (i > 12 && i<=72) {
    animal = animals[i % 12]
    artist = artistNames[i % 12]
    rarity = {
      type: 'string',
      value: 'Obsidian',
      description:
      'Valorize Obsidian NFTs are a collection of 60 NFTs as each Obsidian Art has 5 copies per artist. They grant you the benefits described in the benefits property',
      benefits: [
        'An NFT that is part of the most unique collection of art in NFT history',
        'A large amount of quarterly $VALOR token airdrops',
        'Access to the exclusive membership section of the ValorizeDAO discord',
        'Free access to our upcoming Tokenomics Academy Course',
      ],
    }
  } else if (i > 72 && i <=  312) {
    animal = animals[i % 12]
    artist = artistNames[i % 12]
    rarity = {
      type: 'string',
      value: 'Diamond',
      description:
      'Valorize Diamond NFTs are a collection of 240 NFTs as each Diamond Art has 20 copies per artist. Holding a Diamond NFT will grant you the benefits described in the benefits property',
      benefits: [
        'An NFT that is part of the most unique collection of art in NFT history',
        'An decent amount of quarterly $VALOR token airdrops',
        'Access to the exclusive membership section of the ValorizeDAO discord',
        'Free access to our upcoming Tokenomics Academy Course',
      ],
    }
  } else if (i > 312 && i <= 1032) {
    animal = animals[i % 12]
    artist = artistNames[i % 12]
    rarity = {
      type: 'string',
      value: 'Gold',
      description:
        'Valorize Gold NFTs are a collection of 720 NFTs as each Gold Art has 60 copies per artist. Holding a Gold NFT will grant you the benefits described in the benefits property',
      benefits: [
        'An NFT that is part of the most unique collection of art in NFT history',
        'A moderate amount of quarterly $VALOR token airdrops',
        'Access to the exclusive membership section of the ValorizeDAO discord',
        'Free access to our upcoming Tokenomics Academy Course',
      ],
    }
  } else if (i > 1032 && i <= 2232) {
    animal = animals[i % 12]
    artist = artistNames[i % 12]
    rarity = {
      type: 'string',
      value: 'Silver',
      description:
        'Valorize Silver NFTs are a collection of 1200 NFTs as each Silver Art has 100 copies. Holding a Silver NFT will grant you the benefits described in the benefits property',
      benefits: [
        'An NFT that is part of the most unique collection of art in NFT history',
        'The lowest amount of quarterly $VALOR token airdrops',
        'Access to the exclusive membership section of the ValorizeDAO discord',
        'Free access to our upcoming Tokenomics Academy Course',
      ],
    }
  }

  let data = {
    title: 'ValorizeDAO Membership NFT',
    image_url: `${BASE_URI}/${i}.png`,
    properties: {
      token_id: i,
      animal,
      artist,
      rarity
    },
  }
  const output = JSON.stringify(data)

  fs.writeFile(outputDir + i + '.json', output, (err) => {
    if (err) throw err
    console.log(`File ${i} has been saved!`)
  })
}
