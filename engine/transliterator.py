# engine/transliterator.py

from mapping import FIDEL


class Transliterator:

    # Common phonetic aliases.
    #
    # These are checked before the generic Fidel rules.
    #
    # Longest patterns must be checked first.

    ALIASES = {
        # Standalone vowels
        "aa": "ኣ",
        "a": "አ",
        "u": "ኡ",
        "i": "ኢ",
        "e": "ኤ",
        "o": "ኦ",

        # Common Ethiopic phonetic forms
        "ha": "ሀ",
        "he": "ሀ",
        "hu": "ሁ",
        "hi": "ሂ",
        "haa": "ሃ",
        "hā": "ሃ",
        "hee": "ሄ",
        "ho": "ሆ",

        "la": "ላ",
        "le": "ለ",
        "lu": "ሉ",
        "li": "ሊ",
        "lee": "ሌ",
        "lo": "ሎ",

        "ma": "ማ",
        "me": "መ",
        "mu": "ሙ",
        "mi": "ሚ",
        "mee": "ሜ",
        "mo": "ሞ",

        "ra": "ራ",
        "re": "ረ",
        "ru": "ሩ",
        "ri": "ሪ",
        "ree": "ሬ",
        "ro": "ሮ",

        "sa": "ሳ",
        "se": "ሰ",
        "su": "ሱ",
        "si": "ሲ",
        "see": "ሴ",
        "so": "ሶ",

        "sha": "ሻ",
        "she": "ሸ",
        "shu": "ሹ",
        "shi": "ሺ",
        "shie": "ሼ",
        "sho": "ሾ",

        "qa": "ቃ",
        "qe": "ቀ",
        "qu": "ቁ",
        "qi": "ቂ",
        "qee": "ቄ",
        "qo": "ቆ",

        "ba": "ባ",
        "be": "በ",
        "bu": "ቡ",
        "bi": "ቢ",
        "bee": "ቤ",
        "bo": "ቦ",

        "va": "ቫ",
        "ve": "ቨ",
        "vu": "ቩ",
        "vi": "ቪ",
        "vee": "ቬ",
        "vo": "ቮ",

        "ta": "ታ",
        "te": "ተ",
        "tu": "ቱ",
        "ti": "ቲ",
        "tee": "ቴ",
        "to": "ቶ",

        "cha": "ቻ",
        "che": "ቸ",
        "chu": "ቹ",
        "chi": "ቺ",
        "chee": "ቼ",
        "cho": "ቾ",

        "na": "ና",
        "ne": "ነ",
        "nu": "ኑ",
        "ni": "ኒ",
        "nee": "ኔ",
        "no": "ኖ",

        "nya": "ኛ",
        "nye": "ኘ",
        "nyu": "ኙ",
        "nyi": "ኚ",
        "nyee": "ኜ",
        "nyo": "ኞ",

        "ka": "ካ",
        "ke": "ከ",
        "ku": "ኩ",
        "ki": "ኪ",
        "kee": "ኬ",
        "ko": "ኮ",

        "wa": "ዋ",
        "we": "ወ",
        "wu": "ዉ",
        "wi": "ዊ",
        "wee": "ዌ",
        "wo": "ዎ",

        "za": "ዛ",
        "ze": "ዘ",
        "zu": "ዙ",
        "zi": "ዚ",
        "zee": "ዜ",
        "zo": "ዞ",

        "ya": "ያ",
        "ye": "የ",
        "yu": "ዩ",
        "yi": "ዪ",
        "yee": "ዬ",
        "yo": "ዮ",

        "da": "ዳ",
        "de": "ደ",
        "du": "ዱ",
        "di": "ዲ",
        "dee": "ዴ",
        "do": "ዶ",

        "ja": "ጃ",
        "je": "ጀ",
        "ju": "ጁ",
        "ji": "ጂ",
        "jee": "ጄ",
        "jo": "ጆ",

        "ga": "ጋ",
        "ge": "ገ",
        "gu": "ጉ",
        "gi": "ጊ",
        "gee": "ጌ",
        "go": "ጎ",

        "tsa": "ጻ",
        "tse": "ጸ",
        "tsu": "ጹ",
        "tsi": "ጺ",
        "tsee": "ጼ",
        "tso": "ጾ",

        "ca": "ጫ",
        "ce": "ጨ",
        "cu": "ጩ",
        "ci": "ጪ",
        "cee": "ጬ",
        "co": "ጮ",

        "fa": "ፋ",
        "fe": "ፈ",
        "fu": "ፉ",
        "fi": "ፊ",
        "fee": "ፌ",
        "fo": "ፎ",

        "pa": "ፓ",
        "pe": "ፐ",
        "pu": "ፑ",
        "pi": "ፒ",
        "pee": "ፔ",
        "po": "ፖ",
    }

    # Characters that can occur as standalone final consonants.
    FINAL_CONSONANTS = {
        "h": "ህ",
        "l": "ል",
        "m": "ም",
        "r": "ር",
        "s": "ስ",
        "sh": "ሽ",
        "q": "ቅ",
        "b": "ብ",
        "v": "ቭ",
        "t": "ት",
        "ch": "ች",
        "n": "ን",
        "ny": "ኝ",
        "k": "ክ",
        "w": "ው",
        "z": "ዝ",
        "y": "ይ",
        "d": "ድ",
        "j": "ጅ",
        "g": "ግ",
        "ts": "ጽ",
        "c": "ጭ",
        "f": "ፍ",
        "p": "ፕ",
    }

    def __init__(self):
        # Longest first.
        self.aliases = sorted(
            self.ALIASES.items(),
            key=lambda item: len(item[0]),
            reverse=True,
        )

        self.final_consonants = sorted(
            self.FINAL_CONSONANTS.items(),
            key=lambda item: len(item[0]),
            reverse=True,
        )

    def transliterate(self, text: str) -> str:

        result = []

        i = 0

        while i < len(text):

            remaining = text[i:].lower()

            # ------------------------------------------------
            # Whitespace
            # ------------------------------------------------

            if text[i].isspace():
                result.append(text[i])
                i += 1
                continue

            # ------------------------------------------------
            # Punctuation
            # ------------------------------------------------

            punctuation = {
                ".": "።",
                ",": "፣",
                ";": "፤",
                ":": "፥",
                "?": "፧",
            }

            if text[i] in punctuation:
                result.append(punctuation[text[i]])
                i += 1
                continue

            # ------------------------------------------------
            # Try aliases
            # ------------------------------------------------

            matched = False

            for latin, fidel in self.aliases:

                if remaining.startswith(latin):

                    result.append(fidel)
                    i += len(latin)

                    matched = True
                    break

            if matched:
                continue

            # ------------------------------------------------
            # Final consonant
            # ------------------------------------------------

            matched = False

            for latin, fidel in self.final_consonants:

                if remaining.startswith(latin):

                    result.append(fidel)
                    i += len(latin)

                    matched = True
                    break

            if matched:
                continue

            # ------------------------------------------------
            # Unknown character
            # ------------------------------------------------

            result.append(text[i])
            i += 1

        return "".join(result)