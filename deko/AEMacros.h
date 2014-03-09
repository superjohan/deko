#define AELOG_LOG(levelName, fmt, ...) NSLog((@"%@ [T:0x%x %@] %s:%d " fmt), levelName, (unsigned int)[NSThread currentThread], ([[NSThread currentThread] isMainThread] ? @"M" : @"S"), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)

#define AELOG_ERROR(fmt, ...) AELOG_LOG(@"ERROR", fmt, ##__VA_ARGS__)

#ifdef DEBUG
#define AELOG_DEBUG(fmt, ...) AELOG_LOG(@"DEBUG", fmt, ##__VA_ARGS__)
#define AEAssert(condition) do { if ( ! (condition)) { AELOG_ERROR(@"Expected condition '%s' to be true.", #condition); abort(); } } while(0)
#define AEAssertV(condition, value) do { if ( ! (condition)) { AELOG_ERROR(@"Expected condition '%s' to be true.", #condition); abort(); } } while(0)
#else
#define AELOG_DEBUG(...)
#define AEAssert(condition) do { if ( ! (condition)) { AELOG_ERROR(@"Expected condition '%s' to be true.", #condition); return; } } while(0)
#define AEAssertV(condition, value) do { if ( ! (condition)) { AELOG_ERROR(@"Expected condition '%s' to be true.", #condition); return value; } } while(0)
#endif
