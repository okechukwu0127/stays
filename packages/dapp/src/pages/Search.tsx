import { PageWrapper } from './PageWrapper';
import { SearchForm } from '../components/search/SearchForm';
import { Box } from 'grommet';
import { SearchResultCard } from '../components/SearchResultCard';

export const Search = () => {
  const searchParams = new URLSearchParams(window.location.search)
  const departureDate = searchParams.get('departureDate')
  const returnDate = searchParams.get('returnDate')
  const guestsAmount = searchParams.get('guestsAmount')
  const searchResults = ['asd','asd2','asd3']
  return (
    <PageWrapper
      breadcrumbs={[
        {
          path: '/',
          label: 'Home'
        }
      ]}
    >
      <Box flex={true} align='center' overflow='auto'>
        <Box flex={false} width='xxlarge'>
          <SearchForm
            initReturnDate={returnDate}
            initDepartureDate={departureDate}
            initGuestsAmount={guestsAmount}
          />
          {searchResults.map(() => <SearchResultCard />)}
        </Box>
      </Box>
    </PageWrapper>
  );
};
