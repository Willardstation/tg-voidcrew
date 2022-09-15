/// Cloning room and clone pod ejection
#define ACCESS_CLONING "cloning"

/// New or not new clone
#define CLONER_FRESH_CLONE "fresh"
#define CLONER_MATURE_CLONE "mature"

//cloning defines. These are flags.
#define CLONING_SUCCESS (1<<0)
#define CLONING_DELETE_RECORD (1<<1)

// Ignore defective clones define
#define POLL_IGNORE_DEFECTIVECLONE "defective_clone"

/// Logging
#define LOG_CLONING (1 << 17)
#define INDIVIDUAL_SHOW_ALL_LOG (LOG_ATTACK | LOG_SAY | LOG_WHISPER | LOG_EMOTE | LOG_RADIO_EMOTE | LOG_DSAY | LOG_PDA | LOG_CHAT | LOG_COMMENT | LOG_TELECOMMS | LOG_OOC | LOG_ADMIN | LOG_OWNERSHIP | LOG_GAME | LOG_ADMIN_PRIVATE | LOG_ASAY | LOG_MECHA | LOG_VIRUS | LOG_CLONING | LOG_SHUTTLE | LOG_ECON | LOG_VICTIM)
