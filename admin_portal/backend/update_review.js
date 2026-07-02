const fs = require('fs');
const path = require('path');

const file = path.join('d:', 'shubham', 'wfh', 'admin_portal', 'frontend', 'src', 'components', 'Review.jsx');
let content = fs.readFileSync(file, 'utf8');

// Replace state
content = content.replace(
  `const [forms, setForms] = useState([]);`,
  `const [activeForms, setActiveForms] = useState([]);\n  const [archivedForms, setArchivedForms] = useState([]);\n  const [overallScore, setOverallScore] = useState(candidate?.stats?.overallScore || 0);\n  const [activeCount, setActiveCount] = useState(candidate?.stats?.activeCount || 0);\n  const [archivedCount, setArchivedCount] = useState(candidate?.stats?.archivedCount || 0);`
);

// Update fetch useEffects
content = content.replace(
  /axios\.get\(`\$\{import\.meta\.env\.VITE_API_URL[^]*?finally\(\(\) => setLoading\(false\)\);/m,
  `// Fetch active forms
    const fetchActive = () => {
      setLoading(true);
      axios.get(\`\${import.meta.env.VITE_API_URL || 'https://wfh-g77r.onrender.com'}/api/candidates/\${id}/forms?page=\${currentPage}&limit=\${formsPerPage}&status=active\`)
        .then(res => {
          setActiveForms(res.data.forms);
          if (res.data.stats) {
            setOverallScore(res.data.stats.overallScore);
            setActiveCount(res.data.stats.activeCount);
            setArchivedCount(res.data.stats.archivedCount);
          }
        })
        .finally(() => setLoading(false));
    };

    const fetchArchived = () => {
      axios.get(\`\${import.meta.env.VITE_API_URL || 'https://wfh-g77r.onrender.com'}/api/candidates/\${id}/forms?page=\${archivedPage}&limit=\${formsPerPage}&status=archived\`)
        .then(res => setArchivedForms(res.data.forms));
    };

    fetchActive();
    fetchArchived();
  }, [id, navigate, currentPage, archivedPage]);

  const fetchActiveRef = async () => {
      const res = await axios.get(\`\${import.meta.env.VITE_API_URL || 'https://wfh-g77r.onrender.com'}/api/candidates/\${id}/forms?page=\${currentPage}&limit=\${formsPerPage}&status=active\`);
      setActiveForms(res.data.forms);
      if (res.data.stats) {
        setOverallScore(res.data.stats.overallScore);
        setActiveCount(res.data.stats.activeCount);
        setArchivedCount(res.data.stats.archivedCount);
      }
  };`
);

// Update handleEvaluate
content = content.replace(
  `setForms(forms.map(f => f.id === formId ? { ...f, score: res.data.score, mistakes: res.data.mistakes, status: res.data.status } : f));`,
  `setActiveForms(activeForms.map(f => f.id === formId ? { ...f, score: res.data.score, mistakes: res.data.mistakes, status: res.data.status } : f));`
);

// Update handleAdminScore
content = content.replace(
  `setForms(forms.map(f => f.id === formId ? { ...f, ...res.data.updatedFields, score: res.data.score, mistakes: res.data.mistakes, status: res.data.status } : f));`,
  `setActiveForms(activeForms.map(f => f.id === formId ? { ...f, ...res.data.updatedFields, score: res.data.score, mistakes: res.data.mistakes, status: res.data.status } : f));`
);

// Update handleSend
content = content.replace(
  `setForms(forms.map(f => f.id === formId ? { ...f, status: 'sent' } : f));`,
  `setActiveForms(activeForms.map(f => f.id === formId ? { ...f, status: 'sent' } : f));`
);

// Update handleBulkScore
content = content.replace(/setForms\(res\.data\.forms\);/g, `await fetchActiveRef();`);

// Remove client-side filtering logic
content = content.replace(/const activeForms = forms\.filter\(f => f\.status !== 'archived'\);/, ``);
content = content.replace(/const archivedForms = forms\.filter\(f => f\.status === 'archived'\);/, ``);
content = content.replace(/const totalScoreSum = activeForms\.reduce[^]*?overallScore = [^]*?;/m, ``);

// Fix pagination counts
content = content.replace(/const totalPages = Math\.ceil\(activeForms\.length \/ formsPerPage\);/, `const totalPages = Math.ceil(activeCount / formsPerPage);`);
content = content.replace(/const archivedTotalPages = Math\.ceil\(archivedForms\.length \/ formsPerPage\);/, `const archivedTotalPages = Math.ceil(archivedCount / formsPerPage);`);

// Fix active forms slicing (we don't need slicing anymore!)
content = content.replace(/const indexOfLastForm = currentPage \* formsPerPage;\n\s*const indexOfFirstForm = indexOfLastForm - formsPerPage;\n\s*const currentForms = activeForms\.slice\(indexOfFirstForm, indexOfLastForm\);/, `const currentForms = activeForms;`);

// Fix archived forms slicing
content = content.replace(/const archivedIndexOfLast = archivedPage \* formsPerPage;\n\s*const archivedIndexOfFirst = archivedIndexOfLast - formsPerPage;\n\s*const currentArchived = archivedForms\.slice\(archivedIndexOfFirst, archivedIndexOfLast\);/, `const currentArchived = archivedForms;`);

// Fix header
content = content.replace(/Submitted Forms \(\{activeForms\.length\}\)/, `Submitted Forms ({activeCount})`);
content = content.replace(/overallScore\)\.toFixed\(2\)/, `overallScore).toFixed(2)`);

fs.writeFileSync(file, content);
console.log('Review.jsx updated successfully!');
