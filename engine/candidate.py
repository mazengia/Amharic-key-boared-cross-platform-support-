class CandidateManager:

    def __init__(self):
        self.dictionary = {
            "selam": "ሰላም",
            "abebe": "አበበ",
            "bet": "ቤት",
            "ethiopia": "ኢትዮጵያ",
        }

    def lookup(self, word: str):
        value = self.dictionary.get(word.lower())

        if value is None:
            return []

        return [value]