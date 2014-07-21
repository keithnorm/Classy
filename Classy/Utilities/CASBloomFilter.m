//
//  CASBloomFilter.m
//  CASBloomFilter
//
//  Created by Ryan on 6/4/13.
//  Copyright (c) 2013 Pickmoto. All rights reserved.
//

#import "CASBloomFilter.h"


@interface HashFunctions : NSObject

uint32_t MurmurHash2( const void * key, int len, unsigned int seed );

@end

@implementation HashFunctions

//-----------------------------------------------------------------------------
// MurmurHash2, by Austin Appleby

// Note - This code makes a few assumptions about how your machine behaves -
// 1. We can read a 4-byte value from any address without crashing
// 2. sizeof(int) == 4

// And it has a few limitations -
// 1. It will not work incrementally.
// 2. It will not produce the same results on little-endian and big-endian
//    machines.
uint32_t MurmurHash2( const void * key, int len, unsigned int seed )
{
	// 'm' and 'r' are mixing constants generated offline.
	// They're not really 'magic', they just happen to work well.
    
	const uint32_t m = 0x5bd1e995;
	const int r = 24;
    
	// Initialize the hash to a 'random' value
    
	uint32_t h = seed ^ len;
    
	// Mix 4 bytes at a time into the hash
    
	const unsigned char * data = (const unsigned char *)key;
    
	while(len >= 4)
	{
		uint32_t k = *(uint32_t *)data;
        
		k *= m;
		k ^= k >> r;
		k *= m;
		
		h *= m;
		h ^= k;
        
		data += 4;
		len -= 4;
	}
	
	// Handle the last few bytes of the input array
    
	switch(len)
	{
        case 3: h ^= data[2] << 16;
        case 2: h ^= data[1] << 8;
        case 1: h ^= data[0];
	        h *= m;
	};
    
	// Do a few final mixes of the hash to ensure the last few
	// bytes are well-incorporated.
    
	h ^= h >> 13;
	h *= m;
	h ^= h >> 15;
    
	return h;
}

@end

@interface CASBloomFilter ()
@property(assign, nonatomic) NSInteger numBits;
@property(assign, nonatomic) NSInteger numHashes;
@end

@implementation CASBloomFilter

- (id)initWithNumberOfBits:(NSInteger)bits andWithNumberOfHashes:(NSInteger)hashes {
    self = [super init];
    if(self) {
        self.numBits = bits;
        self.numHashes = hashes;
        self.bitvector = CFBitVectorCreateMutable(NULL, 0);
        CFBitVectorSetAllBits(self.bitvector, 0);
    }
    
    return self;
}

-(void)addToSet:(NSString *)word {
    
    // Initialize the vector
    if(CFBitVectorGetCount(self.bitvector) == 0) {
        CFBitVectorSetCount(self.bitvector, self.numBits);
    }
    
    [self hash:word];
}

-(BOOL)lookup:(NSString *)word {
    const char* str = [word UTF8String];
    int len = [word length];
    
    // Each hash value should provide an index into the bit array
    // Lookup and see if each bit is set. If so, then the word is in the set.
    
    BOOL foundWord = YES;
    uint32_t lastHash = MurmurHash2(str, len, 0);
    for(NSInteger hashCnt = 0; hashCnt < self.numHashes; hashCnt++) {
        
        // Check if the bit is set at the index array (lastHash % self.numBits)
        foundWord = foundWord && CFBitVectorGetBitAtIndex(self.bitvector, (lastHash % self.numBits));
        
        // If not, break immediately
        if(!foundWord) {
            break;
        } else {
            // Hash the previous hash to get a new index
            lastHash = MurmurHash2(str, len, lastHash);
        }
    }
    
    return foundWord;
}

- (void)hash:(NSString *)word {
    const char* str = [word UTF8String];
    int len = [word length];
    
    // Each hash value should provide an index into the bit array
    // Set the bit for each array index that is created for each hash value
    
    uint32_t lastHash = MurmurHash2(str, len, 0);
    for(NSInteger hashCnt = 0; hashCnt < self.numHashes; hashCnt++) {
        
        // Check if the bit is set at the index array (lastHash % self.numBits)
        CFBitVectorSetBitAtIndex(self.bitvector, (lastHash % self.numBits), 1);
        
        // Hash the previous hash to get a new index
        lastHash = MurmurHash2(str, len, lastHash);
    }
}

@end